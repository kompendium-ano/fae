
import React, { useContext, useState } from "react";
import UnlockIcon from "../assets/unlock.svg";
import { BridgeContext } from "../contexts/BridgeContext";
import { Web3Context } from "../contexts/Web3Context";
import { ErrorModal } from "./ErrorModal";


export const UnlockButton = () => {
  const { network, networkMismatch, ethersProvider } = useContext(Web3Context);
  const { fromAmount: amount, fromBalance: balance, allowed, approve } = useContext(BridgeContext);
  const { isOpen, onOpen, onClose } = useDisclosure();
  const [message, setMessage] = useState();
  const onClick = () => {
    setMessage();
    if (ethersProvider && !networkMismatch && window.BigInt(amount) > 0 && window.BigInt(balance) >= window.BigInt(amount)) {
      return approve();
    }
    if (!ethersProvider) {
      setMessage("Please connect wallet");
    } else if (networkMismatch) {
      setMessage(`Please switch wallet to ${network.name}`);
    } else if (window.BigInt(amount) <= 0) {
      setMessage("Please specify amount");
    } else if (window.BigInt(balance) < window.BigInt(amount)) {
      setMessage("Not enough balance");
    }
    return onOpen();
  };
  return (
    <Flex
      align="center"
      as="button"
      color="cyan.500"
      _hover={
        allowed
          ? undefined
          : {
              color: "cyan.600"
            }
      }
      cursor={allowed ? "not-allowed" : "pointer"}
      transition="0.25s"
      position="relative"
      opacity={allowed ? 0.4 : 1}
      onClick={() => {
        if (!allowed) onClick();
      }}
      borderRadius="0.25rem"
      w={{ base: "13rem", lg: "auto" }}
    >
      {isOpen && <ErrorModal message={message} isOpen={isOpen} onClose={onClose} />}
      <svg width="100%" viewBox="0 0 156 42" fill="none">
        <path
          d="M139.086 39.72a4 4 0 01-3.612 2.28H20.526a4 4 0 01-3.612-2.28l-16.19-34C-.54 3.065 1.395 0 4.335 0h147.33c2.94 0 4.875 3.065 3.611 5.72l-16.19 34z"
          fill="currentColor"
        />
      </svg>
      <Flex position="absolute" w="100%" h="100%" justify="center" align="center">
        <Text color="white" fontWeight="bold">
          {allowed ? "Unlocked" : "Unlock"}
        </Text>
        <Image src={UnlockIcon} ml={2} />
      </Flex>
    </Flex>
  );
};
