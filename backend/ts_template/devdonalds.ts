import express, { Request, Response } from "express";

// ==== Type Definitions, feel free to add or modify ==========================

interface RequiredItem {
  name: string;
  quantity: number;
}

interface Ingredient {
  name: string;
  cookTime: number;
}

interface Recipe {
  name: string;
  requiredItems: Array<RequiredItem>;
}

interface Cookbook {
  ingredients: { [name: string]: Ingredient };
  recipes: { [name: string]: Recipe };
}

// =============================================================================
// ==== HTTP Endpoint Stubs ====================================================
// =============================================================================
const app = express();
app.use(express.json());

// Store your recipes here!
const cookbook: Cookbook = {
  ingredients: {},
  recipes: {},
};

// Task 1 helper (don't touch)
app.post("/parse", (req:Request, res:Response) => {
  const { input } = req.body;

  const parsed_string = parse_handwriting(input)
  if (parsed_string == null) {
    res.status(400).send("this string is cooked");
    return;
  } 
  res.json({ msg: parsed_string });
  return;
  
});

// [TASK 1] ====================================================================
// Takes in a recipeName and returns it in a form that 
const parse_handwriting = (recipeName: string): string | null => {
  let res = '';
  let needsCapital = true;

  const aCharCode   = 'a'.charCodeAt(0);
  const zCharCode   = 'z'.charCodeAt(0);
  const ACharCode   = 'A'.charCodeAt(0);
  const ZCharCode   = 'Z'.charCodeAt(0);
  const difference  = aCharCode - ACharCode; 

  for (const c of recipeName) {

    if (c === ' ' || c === '_' || c === '-') {
      res += ' ';
      needsCapital = true;
      continue;
    }

    const charCode = c.charCodeAt(0);
    if (charCode >= aCharCode && charCode <= zCharCode) {
      if (needsCapital) {
        res += String.fromCharCode(charCode - difference)
        needsCapital = false;
      } else {
        res += c;
      }
      continue;
    }

    if (charCode >= ACharCode && charCode <= ZCharCode) {
      if (needsCapital) {
        res += c;
        needsCapital = false;
      } else {
        res += String.fromCharCode(charCode + difference);
      }
      continue;
    }

  }

  return res.length > 0 ? res : null;
}

// [TASK 2] ====================================================================
// Endpoint that adds a CookbookEntry to your magical cookbook
app.post("/entry", (req:Request, res:Response) => {

  const handleInvalid = (res: Response): void => {
    res.status(400).send();
  };

  const body = req.body;
  if (!(typeof body === 'object')) {
    return handleInvalid(res);
  }
  
  const name = body.name;
  const type = body.type;
  if (
    !(typeof name === 'string') || !(typeof type === 'string') || 
    (name in cookbook.ingredients) || (name in cookbook.recipes)
  ) {
    return handleInvalid(res);
  }

  switch (type) {
    case 'recipe':
      const requiredItems = body.requiredItems;
      if (!Array.isArray(requiredItems)) {
        return handleInvalid(res);
      }
      const collectedRequiredItems: Array<RequiredItem> = [];
      const seenItemNames = new Set<string>()
      for (const item of requiredItems) {
        const itemName = item.name;
        const quantity = item.quantity;
        if (
          !(typeof name === 'string') || !(typeof quantity === 'number') ||
          seenItemNames.has(itemName)
        ) {
          return handleInvalid(res);
        }
        seenItemNames.add(item)
        collectedRequiredItems.push({
          name: itemName,
          quantity: quantity,
        });
      }
      cookbook.recipes[name] = {
        name: name,
        requiredItems: collectedRequiredItems,
      };
      break;
    case 'ingredient':
      const cookTime = body.cookTime;
      if (!(typeof cookTime === 'number') || !(cookTime >= 0)) {
        return handleInvalid(res);
      }
      cookbook.ingredients[name] = {
        name: name,
        cookTime: cookTime,
      };
      break;
    default:
      return handleInvalid(res);
  }
  res.status(200).send({});
});

// [TASK 3] ====================================================================
// Endpoint that returns a summary of a recipe that corresponds to a query name
app.get("/summary", (req:Request, res:Response) => {

  const handleInvalid = (res: Response): void => {
    res.status(400).send();
  };

  const requestedName = req.query.name;
  if (
    !(typeof requestedName === 'string') ||
    !(requestedName in cookbook.recipes)
  ) {
    return handleInvalid(res);
  }
  const recipe = cookbook.recipes[requestedName]
  let totalCookTime = 0;

  for (const requiredItem of recipe.requiredItems) {
    if (!(requiredItem.name in cookbook.ingredients)) {
      return handleInvalid(res);
    }
    const ingredient = cookbook.ingredients[requiredItem.name]
    totalCookTime += ingredient.cookTime * requiredItem.quantity;
  }

  return res.status(200).send({
    name: requestedName,
    cookTime: totalCookTime,
    ingredients: recipe.requiredItems
  });
});

// =============================================================================
// ==== DO NOT TOUCH ===========================================================
// =============================================================================
const port = 8080;
app.listen(port, () => {
  console.log(`Running on: http://127.0.0.1:8080`);
});
