import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create new recipe",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const recipe = {
      title: "Perfect Pour Over",
      ingredients: "Coffee beans, Hot water",
      instructions: "Grind beans, pour water in circular motion"
    };
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "recipe-manager",
        "create-recipe",
        [types.ascii(recipe.title), types.utf8(recipe.ingredients), types.utf8(recipe.instructions)],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts[0].result.expectOk(), "u1");
  },
});

Clarinet.test({
  name: "Can rate recipe and calculate average",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const user1 = accounts.get("wallet_1")!;
    const user2 = accounts.get("wallet_2")!;
    
    // Create recipe
    let block = chain.mineBlock([
      Tx.contractCall(
        "recipe-manager",
        "create-recipe",
        [types.ascii("Test Recipe"), types.utf8("Ingredients"), types.utf8("Instructions")],
        user1.address
      )
    ]);
    
    // Rate recipe
    block = chain.mineBlock([
      Tx.contractCall(
        "recipe-manager",
        "rate-recipe",
        [types.uint(1), types.uint(4)],
        user1.address
      ),
      Tx.contractCall(
        "recipe-manager",
        "rate-recipe",
        [types.uint(1), types.uint(5)],
        user2.address
      )
    ]);
    
    // Check average rating
    block = chain.mineBlock([
      Tx.contractCall(
        "recipe-manager",
        "get-recipe-rating",
        [types.uint(1)],
        user1.address
      )
    ]);
    
    assertEquals(block.receipts[0].result.expectOk(), "u4");
  },
});
