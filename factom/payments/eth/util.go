package payments

import (
	"fmt"
	"strings"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/spf13/viper"
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

// https://github.com/ethereum/go-ethereum/blob/55599ee95d4151a2502465e0afc7c47bd1acba77/internal/ethapi/api.go#L404
// signHash is a helper function that calculates a hash for the given message that can be
// safely used to calculate a signature from.
//
// The hash is calculated as
//   keccak256("\x19Ethereum Signed Message:\n"${message length}${message}).
//
// This gives context to the signed message and prevents signing of transactions.
func SignHash(data []byte) []byte {
	msg := fmt.Sprintf("\x19Ethereum Signed Message:\n%d%s", len(data), data)
	return crypto.Keccak256([]byte(msg))
}

func CalculateRewardsDay(timestamp int64) int64 {
	secondsFromRewardsStartTimestamp := timestamp - viper.GetInt64("rewards_start_timestamp")
	secondsInDay := viper.GetInt64("seconds_in_day")
	ret := (secondsFromRewardsStartTimestamp / secondsInDay) + 1
	if ret < 0 && (secondsFromRewardsStartTimestamp%secondsInDay) != 0 {
		ret = ret - 1
	}
	/*
		logger.Infof("*********** secondsFromStart/secondInDay = %v, timestamp = %v, start_timestamp = %v, secondsInDay = %v, ret = %v",
			secondsFromRewardsStartTimestamp / secondsInDay, timestamp, viper.GetInt64("rewards_start_timestamp"), secondsInDay, ret)
	*/
	return ret
}

// Abs returns the absolute value of x.
func Abs(x int64) int64 {
	if x < 0 {
		return -x
	}
	return x
}
