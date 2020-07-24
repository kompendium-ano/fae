const BigNumber = require('bignumber.js');

const constant = require('../../constant');
const Entry = require('factom/src/entry').Entry;
const Chain = require('factom/src/chain').Chain;

describe('Issuance Unit', function() {

    it('Issuance From Object', function() {
        let Issuance = require('../../0/Issuance');
        const data = {
            "chainid": "0cccd100a1801c0cf4aa2104b15dec94fe6f45d0f3347b016ed20d81059494df",
            "tokenid": "test",
            "issuerid": "888888ab72e748840d82c39213c969a11ca6cb026f1d3da39fd82b95b3c1fced",
            "entryhash": "fc0f57ea3a4dc5b8ffc1a9c051f4b6ae0cd7137f9110b98e3c3eb08f132a5e18",
            "timestamp": 1550612940,
            "issuance": {
                "type": "FAT-0",
                "supply": 100000000,
                "precision": 18,
                "symbol": "WLT",
                "metadata": { "custom-field": "wealth token" }
            }
        };

        const issuance = new Issuance(data);
    });
});