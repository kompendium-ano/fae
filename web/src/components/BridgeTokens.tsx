import { Flex, Grid, Text, useBreakpointValue } from '@chakra-ui/core';
import React, { useContext } from 'react';

import { BridgeContext } from '../contexts/BridgeContext';
import { Web3Context } from '../contexts/Web3Context';

export const BridgeTokens = () => {
  const { network } = useContext(Web3Context);
  const { fromToken } = useContext(BridgeContext);
  const isERC20Token = isERC20TokenAddress(fromToken);
  const smallScreen = useBreakpointValue({ base: true, lg: false });

  return (
    <Flex
      w="calc(100% - 2rem)"
      maxW="75rem"
      background="white"
      boxShadow="0px 1rem 2rem rgba(204, 218, 238, 0.8)"
      borderRadius="1rem"
      direction="column"
      align="center"
      p={{ base: 4, md: 8 }}
      mx={4}
      my="auto"
    >
    
    </Flex>
  );
};