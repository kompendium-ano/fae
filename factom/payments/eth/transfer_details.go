package payments

import (
	"context"
	"encoding/hex"
	"fmt"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/propsproject/goprops-toolkit/propstoken/bindings/token"
	"github.com/spf13/viper"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
	"math/big"
	"os"
	"sync"
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
