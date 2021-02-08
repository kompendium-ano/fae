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

// used for tests
//
//func main() {
//	fmt.Println(verifySig(
//		"0x424314B6E4dfeC4b703F2c6fDba28F1724094D11",
//		"0x..", // signature hex
//		[]byte("kompendium"), //message
//	))
//}

func VerifySig(from, sigHex string, msg []byte) bool {
	fromAddr := common.HexToAddress(from)

	sig := hexutil.MustDecode(sigHex)
	// https://github.com/ethereum/go-ethereum/blob/55599ee95d4151a2502465e0afc7c47bd1acba77/internal/ethapi/api.go#L442
	if sig[64] == 27 || sig[64] == 28 {
		sig[64] -= 27
	}

	if sig[64] != 0 && sig[64] != 1 {
		return false
	}

	pubKey, err := crypto.SigToPub(SignHash(msg), sig)
	if err != nil {
		return false
	}

	recoveredAddr := crypto.PubkeyToAddress(*pubKey)

	return fromAddr == recoveredAddr
}
