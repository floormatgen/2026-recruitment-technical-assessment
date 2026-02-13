from dataclasses import dataclass
from typing import Union, Final, Any
from flask import Flask, request, jsonify, Response
# import re

# ==== Type Definitions, feel free to add or modify ===========================
@dataclass
class RequiredItem():
	name: str
	quantity: int

@dataclass
class Recipe():
	name: str
	required_items: list[RequiredItem]

@dataclass
class Ingredient():
	name: str
	cook_time: int

@dataclass
class Cookbook():
	recipes: dict[str, Recipe]
	ingredients: dict[str, Ingredient]


# =============================================================================
# ==== HTTP Endpoint Stubs ====================================================
# =============================================================================
app = Flask(__name__)

# Store your recipes here!
cookbook = Cookbook({}, {})

# Task 1 helper (don't touch)
@app.route("/parse", methods=['POST'])
def parse():
	data = request.get_json()
	recipe_name = data.get('input', '')
	parsed_name = parse_handwriting(recipe_name)
	if parsed_name is None:
		return 'Invalid recipe name', 400
	return jsonify({'msg': parsed_name}), 200

# [TASK 1] ====================================================================
# Takes in a recipeName and returns it in a form that 
def parse_handwriting(recipeName: str) -> Union[str, None]:
	res: str = ""
	requires_capital: bool = True

	char_code_a: Final[int] = ord('a')
	char_code_z: Final[int] = ord('z')
	char_code_A: Final[int] = ord('A')
	char_code_Z: Final[int] = ord('Z')
	difference: Final[int] = char_code_a - char_code_A
	
	for c in recipeName:
		char_code = ord(c)

		if c == ' ' or c == '-' or c == '_':
			res += ' '
			requires_capital = True
			continue
		
		if char_code_a <= char_code and char_code <= char_code_z:
			if requires_capital:
				res += chr(char_code - difference)
				requires_capital = False
			else:
				res += c
			continue

		if char_code_A <= char_code and char_code <= char_code_Z:
			if requires_capital:
				res += c
				requires_capital = False
			else:
				res += chr(char_code + difference)
			continue

	if len(res) > 0:
		return res
	else:
		return None


# [TASK 2] ====================================================================
# Endpoint that adds a CookbookEntry to your magical cookbook
@app.route('/entry', methods=['POST'])
def create_entry() -> Response:
	global cookbook

	def handle_bad_request() -> Response:
		return Response(status=400)

	body = request.get_json(silent=True)
	if body is None:
		return handle_bad_request()
	item_type = body["type"]
	name = body["name"]
	if (
		(type(item_type) is not str) or (type(name) is not str) or
		(name in cookbook.recipes) or (name in cookbook.ingredients)
	):
		return handle_bad_request()
	match item_type:
		case "recipe":
			unverified_required_items = body["requiredItems"]
			if type(unverified_required_items) is not list:
				return handle_bad_request()
			unverified_required_items: list[Any]
			collected_items: list[RequiredItem] = []
			for unverified_item in unverified_required_items:
				if unverified_item is None:
					return handle_bad_request()
				item_name = unverified_item["name"]
				quantity = unverified_item["quantity"]
				if (
					(type(item_name) is not str) or (type(quantity) is not int) or
					quantity < 0
				):
					return handle_bad_request()
				collected_items.append(RequiredItem(item_name, quantity))
			cookbook.recipes[name] = Recipe(name, collected_items)
		case "ingredient":
			cook_time = body["cookTime"]
			if (
				(type(cook_time) is not int) or
				cook_time < 0
			):
				return handle_bad_request()
			cookbook.ingredients[name] = Ingredient(name, cook_time)
		case _:
			return handle_bad_request()
	return Response(status=200)


# [TASK 3] ====================================================================
# Endpoint that returns a summary of a recipe that corresponds to a query name
@app.route('/summary', methods=['GET'])
def summary() -> Response:
	global cookbook

	def handle_bad_request() -> Response:
		return Response(status=400)

	name = request.args["name"]
	if type(name) is not str:
		return handle_bad_request()
	recipe = cookbook.recipes.get(name)
	if recipe is None:
		return handle_bad_request()
	
	total_cook_time = 0
	for required_item in recipe.required_items:
		ingredient = cookbook.ingredients.get(required_item.name)
		if ingredient is None:
			return handle_bad_request()
		total_cook_time += ingredient.cook_time * required_item.quantity
	
	return Response({
		"name": name,
		"cookTime": total_cook_time,
		"ingredients": recipe.required_items
	})
		
	

# =============================================================================
# ==== DO NOT TOUCH ===========================================================
# =============================================================================

if __name__ == '__main__':
	app.run(debug=True, port=8080)
