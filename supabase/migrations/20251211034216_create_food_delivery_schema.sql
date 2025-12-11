/*
  # Food Delivery Platform Schema

  1. New Tables
    - `restaurants`
      - `id` (uuid, primary key)
      - `name` (text)
      - `description` (text)
      - `image_url` (text)
      - `rating` (numeric)
      - `delivery_time` (text)
      - `created_at` (timestamptz)
    
    - `menu_items`
      - `id` (uuid, primary key)
      - `restaurant_id` (uuid, foreign key)
      - `name` (text)
      - `description` (text)
      - `price` (numeric)
      - `image_url` (text)
      - `category` (text)
      - `created_at` (timestamptz)
    
    - `orders`
      - `id` (uuid, primary key)
      - `customer_name` (text)
      - `customer_email` (text)
      - `customer_phone` (text)
      - `delivery_address` (text)
      - `total_amount` (numeric)
      - `status` (text)
      - `created_at` (timestamptz)
    
    - `order_items`
      - `id` (uuid, primary key)
      - `order_id` (uuid, foreign key)
      - `menu_item_id` (uuid, foreign key)
      - `quantity` (integer)
      - `price` (numeric)

  2. Security
    - Enable RLS on all tables
    - Add policies for public read access
    - Add policies for order creation
*/

CREATE TABLE IF NOT EXISTS restaurants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text NOT NULL,
  image_url text NOT NULL,
  rating numeric DEFAULT 4.5,
  delivery_time text NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS menu_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id uuid REFERENCES restaurants(id) ON DELETE CASCADE NOT NULL,
  name text NOT NULL,
  description text NOT NULL,
  price numeric NOT NULL,
  image_url text NOT NULL,
  category text NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_name text NOT NULL,
  customer_email text NOT NULL,
  customer_phone text NOT NULL,
  delivery_address text NOT NULL,
  total_amount numeric NOT NULL,
  status text DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
  menu_item_id uuid REFERENCES menu_items(id) NOT NULL,
  quantity integer NOT NULL,
  price numeric NOT NULL
);

ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view restaurants"
  ON restaurants FOR SELECT
  USING (true);

CREATE POLICY "Anyone can view menu items"
  ON menu_items FOR SELECT
  USING (true);

CREATE POLICY "Anyone can create orders"
  ON orders FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Anyone can create order items"
  ON order_items FOR INSERT
  WITH CHECK (true);

INSERT INTO restaurants (name, description, image_url, rating, delivery_time) VALUES
  ('Pizza Palace', 'Authentic Italian pizzas with fresh ingredients', 'https://images.pexels.com/photos/1566837/pexels-photo-1566837.jpeg?auto=compress&cs=tinysrgb&w=400', 4.8, '25-35 min'),
  ('Burger Hub', 'Gourmet burgers and crispy fries', 'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg?auto=compress&cs=tinysrgb&w=400', 4.6, '20-30 min'),
  ('Sushi Express', 'Fresh sushi and Japanese cuisine', 'https://images.pexels.com/photos/2098085/pexels-photo-2098085.jpeg?auto=compress&cs=tinysrgb&w=400', 4.9, '30-40 min'),
  ('Taco Fiesta', 'Authentic Mexican tacos and burritos', 'https://images.pexels.com/photos/4958792/pexels-photo-4958792.jpeg?auto=compress&cs=tinysrgb&w=400', 4.7, '15-25 min');

INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category) 
SELECT 
  r.id,
  item.name,
  item.description,
  item.price,
  item.image_url,
  item.category
FROM restaurants r
CROSS JOIN (
  VALUES
    ('Margherita Pizza', 'Classic tomato sauce, mozzarella, and basil', 12.99, 'https://images.pexels.com/photos/905847/pexels-photo-905847.jpeg?auto=compress&cs=tinysrgb&w=400', 'Pizza'),
    ('Pepperoni Pizza', 'Loaded with pepperoni and cheese', 14.99, 'https://images.pexels.com/photos/2147491/pexels-photo-2147491.jpeg?auto=compress&cs=tinysrgb&w=400', 'Pizza'),
    ('Veggie Supreme', 'Fresh vegetables and herbs', 13.99, 'https://images.pexels.com/photos/1653877/pexels-photo-1653877.jpeg?auto=compress&cs=tinysrgb&w=400', 'Pizza')
) AS item(name, description, price, image_url, category)
WHERE r.name = 'Pizza Palace';

INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category)
SELECT 
  r.id,
  item.name,
  item.description,
  item.price,
  item.image_url,
  item.category
FROM restaurants r
CROSS JOIN (
  VALUES
    ('Classic Burger', 'Beef patty with lettuce, tomato, onion', 9.99, 'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg?auto=compress&cs=tinysrgb&w=400', 'Burger'),
    ('Cheese Burger', 'Double cheese and bacon', 11.99, 'https://images.pexels.com/photos/580612/pexels-photo-580612.jpeg?auto=compress&cs=tinysrgb&w=400', 'Burger'),
    ('Crispy Fries', 'Golden crispy french fries', 4.99, 'https://images.pexels.com/photos/1893556/pexels-photo-1893556.jpeg?auto=compress&cs=tinysrgb&w=400', 'Sides')
) AS item(name, description, price, image_url, category)
WHERE r.name = 'Burger Hub';