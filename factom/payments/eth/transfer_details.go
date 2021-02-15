package rewards

import (
	"context"
	"encoding/hex"
	"fmt"
	"math/big"
	"os"
	"sync"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/spf13/viper"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

type TransferDetails struct {
	TimeStamp *big.Int       `json:"timestamp"`
	Address   common.Address `json:"address"`
	Balance   *big.Int       `json:"balance"`
	Amount    *big.Int       `json:"amount"`
	From      common.Address `json:"from"`
	To        common.Address `json:"to"`
}

type SettlementDetails struct {
	TimeStamp     *big.Int       `json:"timestamp"`
	Amount        *big.Int       `json:"amount"`
	From          common.Address `json:"from"`
	To            common.Address `json:"to"`
	ApplicationId common.Address `json:"applicationId"`
	UserId        string         `json:"userId"`
	Balance       *big.Int       `json:"balance"`
}

type SettlementEvent struct {
	From           common.Address
	UserId         string
	To             common.Address
	Amount         *big.Int
	RewardsAddress common.Address
}

var atom = zap.NewAtomicLevel()
var encoderCfg = zap.NewProductionEncoderConfig()
var logger *zap.SugaredLogger

var doOnce sync.Once

func initLogger() {
	doOnce.Do(func() {
		encoderCfg.TimeKey = "timestamp"
		encoderCfg.EncodeTime = zapcore.ISO8601TimeEncoder
		atom.SetLevel(zap.DebugLevel)

		var tmpLogger = zap.New(zapcore.NewCore(
			zapcore.NewJSONEncoder(encoderCfg),
			zapcore.Lock(os.Stdout),
			atom,
		))

		tmpLogger = tmpLogger.With(
			zap.String("app", viper.GetString("app")),
			zap.String("name", viper.GetString("name")),
			zap.String("env", viper.GetString("environment")),
		)

		defer tmpLogger.Sync()

		logger = tmpLogger.Sugar()
	})
}

func GetEthTransactionTransferDetails(transactionHash string, address string, client *propstoken.Client) (*TransferDetails, uint64, error) {

	initLogger()

	logger.Infof("GetEthTransactionTransferDetails TransactionHash %s ((balanceUpdate for %v)", transactionHash, address)
	transaction, err := client.RPC.TransactionReceipt(context.Background(), common.HexToHash(transactionHash))
	if err != nil {
		return nil, 0, fmt.Errorf("unable to get transaction receipt for hash (%s)", err)
	}

	for _, log := range transaction.Logs {
		topics := log.Topics
		sig := topics[0].Hex()
		if sig == "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef" { // only if matches Transfer signature keccak256(Transfer(address,address,uint256))
			from := NormalizeAddress(fmt.Sprintf("0x%v", topics[1].Hex()[26:]))
			to := NormalizeAddress(fmt.Sprintf("0x%v", topics[2].Hex()[26:]))
			logger.Infof("GetEthTransactionTransferDetails checking addresses from=0x%v, to=0x%v address=%v", from, to, address)
			if address == from || address == to {

			} else {
				if (from == "0x0000000000000000000000000000000000000000" && to != address) || (to == "0x0000000000000000000000000000000000000000" && from != address) {
					logger.Infof("GetEthTransactionTransferDetails skipping due to from/to address being 0 (balanceUpdate for %v)", address)
					continue
				}
				logger.Infof("transaction %v address does not match reported balance update address %v, %v do not match %v", transactionHash, from, to, address)
				return nil, 0, fmt.Errorf("transaction %v address does not match reported balance update address %v, %v do not match %v", transactionHash, from, to, address)
			}

			callOptions := bind.CallOpts{
				Pending:     false,
				BlockNumber: new(big.Int).SetUint64(log.BlockNumber),
			}
			balance, err := client.Token.BalanceOf(&callOptions, common.HexToAddress(address))
			if err != nil {
				logger.Infof("unable to get balanceOf %v on block %v (%s)", address, log.BlockNumber, err)
				return nil, 0, fmt.Errorf("unable to get balanceOf %v on block %v (%s)", address, log.BlockNumber, err)
			} else {
				logger.Infof("GetEthTransactionTransferDetails balance %v blockNumber %v (log.BlockNumber %v)", balance.String(), callOptions.BlockNumber.String(), log.BlockNumber)
			}

			transferDetails := TransferDetails{
				Address: common.HexToAddress(NormalizeAddress(address)),
				Balance: balance,
				Amount:  new(big.Int).SetBytes(log.Data),
				From:    common.HexToAddress(from),
				To:      common.HexToAddress(to),
			}
			logger.Infof("GetEthTransactionTransferDetails got transfer details amount=%v (balanceUpdate for %v)", transferDetails.Amount.String(), address)
			return &transferDetails, log.BlockNumber, nil
		} else {
			logger.Infof("GetEthTransactionTransferDetails signature didn't match transfer got sig=%v (balanceUpdate for %v)", sig, address)
		}
	}
	logger.Infof("unable to get TransferDetails data from transaction (%s) (balanceUpdate for %v)", transactionHash, address)
	return nil, 0, fmt.Errorf("unable to get TransferDetails data from transaction (%s)", transactionHash)
}

func GetEthTransactionSettlementDetails(transactionHash string, client *propstoken.Client) (*SettlementDetails, uint64, error) {

	initLogger()

	logger.Infof("GetEthTransactionSettlementDetails TransactionHash %s", transactionHash)
	transaction, err := client.RPC.TransactionReceipt(context.Background(), common.HexToHash(transactionHash))
	if err != nil {
		return nil, 0, fmt.Errorf("unable to get transaction receipt for hash (%s)", err)
	}

	for _, log := range transaction.Logs {
		topics := log.Topics
		sig := topics[0].Hex()
		logger.Infof("GetEthTransactionSettlementDetails sig=%v", sig)
		if sig == "0x53b5073ff19aef23b167e83c6be14817da210375bec35b4c0ccfc0cded9a23f8" { // only if matches Transfer signature keccak256(Settlement(address,bytes32,address,uint256,address))
			var settlementEvent SettlementEvent
			applicationId := common.HexToAddress(topics[1].Hex())
			userId, err := hex.DecodeString(topics[2].Hex()[2:])
			logger.Infof("GetEthTransactionSettlementDetails applicationId:%v, userId:%v, err:%v topcis[2].hex:%v", applicationId.String(), string(userId), err, topics[2].Hex()[2:])
			if err != nil {
				return nil, 0, fmt.Errorf("unable to decode userId %v (%s)", topics[2].Hex(), err)
			}
			to := common.HexToAddress(NormalizeAddress(topics[3].Hex()))
			err1 := client.ABI.Unpack(&settlementEvent, "Settlement", log.Data)
			if err1 != nil {
				return nil, 0, fmt.Errorf("unable to unpack log.Data %v (%s)", log.Data, err1)
			}

			callOptions := bind.CallOpts{
				Pending:     false,
				BlockNumber: new(big.Int).SetUint64(log.BlockNumber),
			}
			balance, err := client.Token.BalanceOf(&callOptions, to)
			if err != nil {
				logger.Infof("GetEthTransactionSettlementDetails> unable to get balanceOf %v on block %v (%s)", to, log.BlockNumber, err)
				return nil, 0, fmt.Errorf("GetEthTransactionSettlementDetails: unable to get balanceOf %v on block %v (%s)", to, log.BlockNumber, err)
			} else {
				logger.Infof("GetEthTransactionSettlementDetails: balance %v blockNumber %v (log.BlockNumber %v)", balance.String(), callOptions.BlockNumber.String(), log.BlockNumber)
			}

			settlementDetails := SettlementDetails{
				Amount:        settlementEvent.Amount,
				From:          settlementEvent.RewardsAddress,
				To:            to,
				ApplicationId: applicationId,
				UserId:        string(userId),
				Balance:       balance,
			}

			logger.Infof("GetEthTransactionSettlementDetails got %v ", settlementDetails)
			return &settlementDetails, log.BlockNumber, nil
		} else {
			logger.Infof("GetEthTransactionSettlementDetails signature didn't match settlement got sig=%v", sig)
		}
	}
	logger.Infof("unable to get SettlementDetails data from transaction (%s)", transactionHash)
	return nil, 0, fmt.Errorf("unable to get TransferDetails data from transaction (%s)", transactionHash)
}
