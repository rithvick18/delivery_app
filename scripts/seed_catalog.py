#!/usr/bin/env python3
"""
Seed script to populate Supabase database with stores, products, and inventory mappings.
- 10 Stores
- 200 Products across 6 categories
- 2,000 Store Inventory mappings (200 products x 10 stores)

Uses curated Unsplash HTTP photo URLs for all products and stores.
"""

import os
import random
import uuid
from faker import Faker
from supabase import create_client, Client
from typing import List, Dict, Any

# Initialize Faker for realistic data
fake = Faker()

# Supabase Configuration
SUPABASE_URL = os.getenv("SUPABASE_URL", "https://idiqnfrpbslnagkmuvck.supabase.co")
SUPABASE_SERVICE_ROLE_KEY = os.getenv(
    "SUPABASE_SERVICE_ROLE_KEY",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlkaXFuZnJwYnNsbmFna211dmNrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NTc0NTg3MCwiZXhwIjoyMTAxMzIxODcwfQ.SoL82AINtVf6LTGLS4VvOlXg0i1upjWb5bjversndk8"
)

# Initialize Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

# Categories for products
CATEGORIES = [
    "Fresh Produce",
    "Dairy & Eggs",
    "Bakery & Bread",
    "Pantry & Staples",
    "Beverages",
    "Snacks"
]

# Units for products
UNITS = ["lb", "ea", "gal", "oz", "pack", "bag", "box", "bottle", "can", "jar"]

# Aisle locations
AISLE_LOCATIONS = [
    "Aisle 1 - Shelf A", "Aisle 1 - Shelf B", "Aisle 1 - Shelf C",
    "Aisle 2 - Shelf A", "Aisle 2 - Shelf B", "Aisle 2 - Shelf C",
    "Aisle 3 - Shelf A", "Aisle 3 - Shelf B", "Aisle 3 - Shelf C",
    "Aisle 4 - Shelf A", "Aisle 4 - Shelf B", "Aisle 4 - Shelf C",
    "Aisle 5 - Shelf A", "Aisle 5 - Shelf B", "Aisle 5 - Shelf C",
    "Aisle 6 - Shelf A", "Aisle 6 - Shelf B", "Aisle 6 - Shelf C",
    "Aisle 7 - Shelf A", "Aisle 7 - Shelf B", "Aisle 7 - Shelf C",
    "Aisle 8 - Shelf A", "Aisle 8 - Shelf B", "Aisle 8 - Shelf C",
]

# High quality Unsplash URLs for stores
STORE_IMAGES = [
    "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1517523791225-289075439574?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1534723452862-4c874018d66d?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1583258292688-d0213dc5a3a8?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1588964895597-cfccd6e2dbf9?w=600&h=400&fit=crop",
]

# Keyword-to-Unsplash image mapping for accurate product photos
KEYWORD_IMAGE_MAP = {
    "Apple": "https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?w=400&h=400&fit=crop",
    "Avocado": "https://images.unsplash.com/photo-1560272564-c83b66b1ad12?w=400&h=400&fit=crop",
    "Banana": "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop",
    "Strawberry": "https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=400&h=400&fit=crop",
    "Blueberry": "https://images.unsplash.com/photo-1498557850523-fd3d118b962e?w=400&h=400&fit=crop",
    "Spinach": "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&h=400&fit=crop",
    "Tomato": "https://images.unsplash.com/photo-1592841200221-21e1c0d36875?w=400&h=400&fit=crop",
    "Broccoli": "https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=400&h=400&fit=crop",
    "Carrot": "https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400&h=400&fit=crop",
    "Grape": "https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=400&h=400&fit=crop",
    "Lemon": "https://images.unsplash.com/photo-1534531141161-e41d133a4be3?w=400&h=400&fit=crop",
    "Orange": "https://images.unsplash.com/photo-1547514701-42782101795e?w=400&h=400&fit=crop",
    "Pepper": "https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=400&h=400&fit=crop",
    "Potato": "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&h=400&fit=crop",
    "Milk": "https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop",
    "Cheese": "https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=400&h=400&fit=crop",
    "Egg": "https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&h=400&fit=crop",
    "Yogurt": "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&h=400&fit=crop",
    "Butter": "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=400&h=400&fit=crop",
    "Bread": "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop",
    "Croissant": "https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&h=400&fit=crop",
    "Bagel": "https://images.unsplash.com/photo-1585478259715-876a6a81fc08?w=400&h=400&fit=crop",
    "Cake": "https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&h=400&fit=crop",
    "Cookie": "https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=400&h=400&fit=crop",
    "Donut": "https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=400&h=400&fit=crop",
    "Pasta": "https://images.unsplash.com/photo-1621996346565-e3d5d6281288?w=400&h=400&fit=crop",
    "Spaghetti": "https://images.unsplash.com/photo-1621996346565-e3d5d6281288?w=400&h=400&fit=crop",
    "Rice": "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop",
    "Bean": "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=400&fit=crop",
    "Cereal": "https://images.unsplash.com/photo-1521483451569-e33803c0330c?w=400&h=400&fit=crop",
    "Honey": "https://images.unsplash.com/photo-1587049352847-4a222e784d38?w=400&h=400&fit=crop",
    "Oil": "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&h=400&fit=crop",
    "Coffee": "https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400&h=400&fit=crop",
    "Tea": "https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=400&h=400&fit=crop",
    "Juice": "https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400&h=400&fit=crop",
    "Soda": "https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400&h=400&fit=crop",
    "Water": "https://images.unsplash.com/photo-1548839140-29a749e1bc4e?w=400&h=400&fit=crop",
    "Chip": "https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400&h=400&fit=crop",
    "Cracker": "https://images.unsplash.com/photo-1599490659213-e2b9527bd087?w=400&h=400&fit=crop",
    "Nut": "https://images.unsplash.com/photo-1536591375315-1b8368813277?w=400&h=400&fit=crop",
    "Popcorn": "https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=400&h=400&fit=crop",
    "Chocolate": "https://images.unsplash.com/photo-1549007994-cb92caebd54b?w=400&h=400&fit=crop",
}

# Category fallback Unsplash photo pools
CATEGORY_IMAGES = {
    "Fresh Produce": [
        "https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1560272564-c83b66b1ad12?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1498557850523-fd3d118b962e?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1534531141161-e41d133a4be3?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1547514701-42782101795e?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1592841200221-21e1c0d36875?w=400&h=400&fit=crop",
    ],
    "Dairy & Eggs": [
        "https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1570197788417-0e82375c9371?w=400&h=400&fit=crop",
    ],
    "Bakery & Bread": [
        "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1585478259715-876a6a81fc08?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=400&h=400&fit=crop",
    ],
    "Pantry & Staples": [
        "https://images.unsplash.com/photo-1621996346565-e3d5d6281288?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1521483451569-e33803c0330c?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1587049352847-4a222e784d38?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&h=400&fit=crop",
    ],
    "Beverages": [
        "https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1548839140-29a749e1bc4e?w=400&h=400&fit=crop",
    ],
    "Snacks": [
        "https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1599490659213-e2b9527bd087?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1536591375315-1b8368813277?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=400&h=400&fit=crop",
        "https://images.unsplash.com/photo-1549007994-cb92caebd54b?w=400&h=400&fit=crop",
    ],
}

def generate_barcode():
    """Generate a realistic EAN-13 barcode."""
    return str(random.randint(1000000000000, 9999999999999))

def generate_store_data() -> tuple[List[Dict[str, Any]], Dict[int, str]]:
    """Generate 10 store records."""
    stores = []
    store_names = [
        "Solaris Supercenter",
        "Solaris Market & Bakery",
        "Solaris Organic Express",
        "FreshMart Grocery",
        "Green Valley Market",
        "Harvest Foods",
        "City Fresh Market",
        "Sunshine Grocers",
        "Elite Supermarket",
        "Neighborhood Mart"
    ]

    addresses = [
        "742 Evergreen Terrace, Springfield",
        "120 Oakridge Blvd, Springfield",
        "405 Pine Street, Springfield",
        "890 Maple Avenue, Springfield",
        "321 Cedar Lane, Springfield",
        "654 Birch Road, Springfield",
        "159 Willow Drive, Springfield",
        "234 Spruce Court, Springfield",
        "789 Elm Street, Springfield",
        "456 Oak Circle, Springfield"
    ]

    tags_pool = [
        ["Open Now", "Live Stock Sync", "30 Min Delivery", "Curbside Pickup"],
        ["Open Now", "Artisanal Bakery", "Local Produce"],
        ["100% Organic", "Farm Direct", "Live Stock Tracking"],
        ["24/7 Open", "Self Checkout", "Pharmacy"],
        ["Bulk Section", "International Foods", "Hot Deli"],
        ["Farmers Market", "Gluten Free", "Vegan Options"],
        ["Online Ordering", "Same Day Delivery", "Senior Discount"],
        ["Student Discount", "Fresh Seafood", "Wine Selection"],
        ["Premium Selection", "Valet Parking", "Gift Cards"],
        ["Community Supported", "Local Vendors", "Fresh Daily"]
    ]

    store_id_map = {}
    for i in range(10):
        s_uuid = str(uuid.uuid4())
        store_id_map[i] = s_uuid
        store = {
            "id": s_uuid,
            "name": store_names[i],
            "address": addresses[i],
            "distance": round(random.uniform(0.5, 5.0), 1),
            "delivery_time": f"{random.randint(15, 45)} mins",
            "is_open": True,
        }
        stores.append(store)

    return stores, store_id_map

def generate_product_data() -> tuple[List[Dict[str, Any]], Dict[int, str]]:
    """Generate 200 product records across 6 categories."""
    products = []
    product_id_map = {}

    produce_names = [
        "Honeycrisp Apples", "Gala Apples", "Fuji Apples", "Granny Smith Apples",
        "Hass Avocados", "Organic Bananas", "Sweet Yellow Strawberries", "Blueberries",
        "Organic Baby Spinach", "Heirloom Tomatoes", "Broccoli Crowns", "Carrots",
        "Red Grapes", "Green Grapes", "Lemons", "Limes", "Oranges", "Bell Peppers",
        "Russet Potatoes", "Sweet Potatoes", "Cucumbers", "Zucchini", "Mushrooms",
        "Celery", "Lettuce", "Kale", "Cauliflower", "Asparagus", "Green Beans",
        "Onions", "Garlic", "Ginger", "Cilantro", "Parsley"
    ]

    dairy_names = [
        "Whole Milk", "2% Milk", "Skim Milk", "Almond Milk", "Oat Milk",
        "Cheddar Cheese", "Mozzarella Cheese", "Swiss Cheese", "Parmesan Cheese",
        "Large Eggs", "Organic Eggs", "Cage Free Eggs", "Greek Yogurt",
        "Vanilla Yogurt", "Strawberry Yogurt", "Butter", "Margarine",
        "Sour Cream", "Cottage Cheese", "Whipping Cream", "Heavy Cream",
        "Ice Cream", "Frozen Yogurt", "Cream Cheese", "Shredded Cheese"
    ]

    bakery_names = [
        "White Bread", "Wheat Bread", "Sourdough Bread", "Multigrain Bread",
        "Baguette", "Ciabatta", "Croissants", "Blueberry Muffins",
        "Chocolate Chip Muffins", "Bagels", "English Muffins", "Tortillas",
        "Pita Bread", "Hamburger Buns", "Hot Dog Buns", "Dinner Rolls",
        "Cinnamon Rolls", "Apple Pie", "Chocolate Cake", "Vanilla Cake",
        "Cookies", "Brownies", "Donuts", "Danish Pastries"
    ]

    pantry_names = [
        "Spaghetti", "Penne Pasta", "Macaroni", "Linguine", "Fettuccine",
        "White Rice", "Brown Rice", "Jasmine Rice", "Basmathi Rice", "Quinoa",
        "Black Beans", "Kidney Beans", "Chickpeas", "Pinto Beans", "Corn",
        "Diced Tomatoes", "Crushed Tomatoes", "Tomato Sauce", "Pasta Sauce",
        "Peanut Butter", "Jelly", "Honey", "Maple Syrup", "Olive Oil",
        "Vegetable Oil", "Canola Oil", "Flour", "Sugar", "Brown Sugar",
        "Oats", "Cereal", "Granola", "Pancake Mix", "Baking Powder",
        "Baking Soda", "Vanilla Extract", "Chicken Broth", "Beef Broth"
    ]

    beverage_names = [
        "Ground Coffee", "Instant Coffee", "Coffee Beans", "Black Tea", "Green Tea",
        "Herbal Tea", "Iced Tea", "Orange Juice", "Apple Juice", "Cranberry Juice",
        "Cola", "Diet Cola", "Lemon Lime Soda", "Root Beer", "Ginger Ale",
        "Sparkling Water", "Bottled Water", "Energy Drink", "Sports Drink",
        "Chocolate Milk", "Strawberry Milk", "Almond Milk Chocolate", "Lemonade",
        "Coconut Water", "Pineapple Juice", "Grapefruit Juice", "Tomato Juice"
    ]

    snack_names = [
        "Potato Chips", "Tortilla Chips", "Pretzels", "Popcorn", "Crackers",
        "Graham Crackers", "Saltine Crackers", "Peanuts", "Cashews", "Almonds",
        "Mixed Nuts", "Trail Mix", "Granola Bars", "Protein Bars", "Chocolate Bars",
        "Candy Bars", "Gummy Bears", "M&M's", "Potato Sticks", "Veggie Chips",
        "Beef Jerky", "Turkey Jerky", "Dried Fruit", "Fruit Snacks", "Rice Cakes"
    ]

    category_products = {
        "Fresh Produce": produce_names,
        "Dairy & Eggs": dairy_names,
        "Bakery & Bread": bakery_names,
        "Pantry & Staples": pantry_names,
        "Beverages": beverage_names,
        "Snacks": snack_names,
    }

    products_per_category = 200 // len(CATEGORIES)
    remainder = 200 % len(CATEGORIES)

    product_idx = 0
    for category in CATEGORIES:
        count = products_per_category + (1 if remainder > 0 else 0)
        remainder -= 1

        names = category_products[category]
        for i in range(count):
            name_idx = i % len(names)
            name = names[name_idx]
            if i >= len(names):
                name = f"{name} {i - len(names) + 1}"

            # Match photo URL by keyword or fallback to category pool
            image_url = None
            for key, url in KEYWORD_IMAGE_MAP.items():
                if key.lower() in name.lower():
                    image_url = url
                    break

            if not image_url:
                pool = CATEGORY_IMAGES.get(category, CATEGORY_IMAGES["Fresh Produce"])
                image_url = pool[i % len(pool)]

            is_organic = random.random() < 0.3
            p_uuid = str(uuid.uuid4())
            product_id_map[product_idx] = p_uuid

            product = {
                "id": p_uuid,
                "sku": f"SKU-{product_idx+1:04d}",
                "name": name,
                "category": category,
                "unit": random.choice(UNITS),
                "barcode": generate_barcode(),
                "is_organic": is_organic,
                "aisle_location": random.choice(AISLE_LOCATIONS),
                "image_url": image_url,
            }
            products.append(product)
            product_idx += 1

    return products, product_id_map

def generate_inventory_data(stores: List[Dict[str, Any]], products: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Generate 2,000 inventory mappings (all products x all stores)."""
    inventory = []

    for store in stores:
        for product in products:
            inventory_item = {
                "id": str(uuid.uuid4()),
                "store_id": store["id"],
                "product_id": product["id"],
                "price": round(random.uniform(0.99, 24.99), 2),
                "stock_count": random.randint(0, 60),
                "stock_confidence": random.randint(70, 100),
                "is_available": True,
            }
            inventory.append(inventory_item)

    return inventory

def clear_existing_data():
    """Clear existing data before re-seeding to ensure clean state."""
    print("Clearing existing data from Supabase...")
    try:
        supabase.table("store_inventory").delete().neq("id", "00000000-0000-0000-0000-000000000000").execute()
        supabase.table("products").delete().neq("id", "00000000-0000-0000-0000-000000000000").execute()
        supabase.table("stores").delete().neq("id", "00000000-0000-0000-0000-000000000000").execute()
        print("  Existing records cleared.")
    except Exception as e:
        print(f"  Note while clearing: {e}")

def seed_database():
    """Main function to seed the database."""
    print("Starting database seeding with Unsplash URLs...")
    clear_existing_data()

    # Generate data
    print("Generating store data...")
    stores, _ = generate_store_data()

    print("Generating product data...")
    products, _ = generate_product_data()

    print("Generating inventory data...")
    inventory = generate_inventory_data(stores, products)

    print(f"Seeding {len(stores)} stores...")
    response = supabase.table("stores").insert(stores).execute()
    if response.data:
        print(f"  Inserted {len(response.data)} stores")
    else:
        print(f"  Error inserting stores")

    print(f"Seeding {len(products)} products...")
    response = supabase.table("products").insert(products).execute()
    if response.data:
        print(f"  Inserted {len(response.data)} products")
    else:
        print(f"  Error inserting products")

    print(f"Seeding {len(inventory)} inventory mappings...")
    batch_size = 500
    for i in range(0, len(inventory), batch_size):
        batch = inventory[i:i + batch_size]
        response = supabase.table("store_inventory").insert(batch).execute()
        if response.data:
            print(f"  Inserted batch {i//batch_size + 1}: {len(response.data)} records")

    print("Database seeding complete!")

if __name__ == "__main__":
    seed_database()