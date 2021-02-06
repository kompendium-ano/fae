package payments

import (
	"fmt"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/spf13/viper"
	"strings"
)

func NormalizeAddress(s string) string {
	if len(s) > 0 {
		if s[:2] != "0x" {
			return fmt.Sprintf("%s%s", "0x", strings.ToLower(s))
		}
		return strings.ToLower(s)
	}
	return s
}
