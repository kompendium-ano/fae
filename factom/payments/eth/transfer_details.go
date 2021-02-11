package payments

import (
	"math/big"
	"os"
	"sync"

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
