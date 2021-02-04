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
