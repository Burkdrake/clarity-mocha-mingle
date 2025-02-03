import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create user profile",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const user1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "user-profiles",
        "create-profile",
        [types.ascii("Coffee Lover"), types.utf8("I love brewing coffee!")],
        user1.address
      )
    ]);
    
    assertEquals(block.receipts[0].result.expectOk(), true);
  },
});
