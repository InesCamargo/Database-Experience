PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS order_item;
DROP TABLE IF EXISTS customer_order;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS customer;

CREATE TABLE customer (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    city TEXT NOT NULL
);

CREATE TABLE product (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0)
);

CREATE TABLE customer_order (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    created_at TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('Pendente', 'Pago', 'Enviado')),
    FOREIGN KEY (customer_id) REFERENCES customer (id)
);

CREATE TABLE order_item (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    item_price NUMERIC NOT NULL CHECK (item_price > 0),
    FOREIGN KEY (order_id) REFERENCES customer_order (id),
    FOREIGN KEY (product_id) REFERENCES product (id)
);

CREATE TABLE payment (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    method TEXT NOT NULL,
    amount NUMERIC NOT NULL CHECK (amount > 0),
    paid_at TEXT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES customer_order (id)
);

INSERT INTO customer (full_name, email, city) VALUES
('Ana Souza', 'ana@example.com', 'São Paulo'),
('Bruno Lima', 'bruno@example.com', 'Recife'),
('Carla Dias', 'carla@example.com', 'Salvador');

INSERT INTO product (name, category, unit_price) VALUES
('Notebook', 'Eletrônicos', 4500.00),
('Mouse', 'Eletrônicos', 120.00),
('Cadeira', 'Móveis', 900.00),
('Teclado', 'Eletrônicos', 250.00);

INSERT INTO customer_order (customer_id, created_at, status) VALUES
(1, '2026-05-10', 'Pago'),
(2, '2026-05-11', 'Pendente'),
(1, '2026-05-12', 'Enviado'),
(3, '2026-05-13', 'Pago');

INSERT INTO order_item (order_id, product_id, quantity, item_price) VALUES
(1, 1, 1, 4500.00),
(1, 2, 1, 120.00),
(2, 3, 1, 900.00),
(3, 4, 2, 250.00),
(4, 2, 3, 120.00);

INSERT INTO payment (order_id, method, amount, paid_at) VALUES
(1, 'Cartão', 4620.00, '2026-05-10'),
(4, 'PIX', 360.00, '2026-05-13');

-- 1) Recuperação simples com SELECT
SELECT id, full_name, city
FROM customer;

-- 2) Filtro com WHERE
SELECT id, name, unit_price
FROM product
WHERE category = 'Eletrônicos';

-- 3) Atributo derivado (subtotal do item)
SELECT order_id, product_id, quantity, item_price,
       quantity * item_price AS item_subtotal
FROM order_item;

-- 4) Ordenação com ORDER BY
SELECT id, created_at, status
FROM customer_order
ORDER BY created_at DESC;

-- 5) Filtro em agrupamento com HAVING
SELECT c.full_name,
       COUNT(o.id) AS total_pedidos
FROM customer c
JOIN customer_order o ON o.customer_id = c.id
GROUP BY c.id, c.full_name
HAVING COUNT(o.id) >= 2;

-- 6) Junção entre tabelas com visão mais complexa
SELECT o.id AS pedido_id,
       c.full_name AS cliente,
       p.name AS produto,
       oi.quantity,
       oi.item_price,
       (oi.quantity * oi.item_price) AS subtotal,
       o.status
FROM customer_order o
JOIN customer c ON c.id = o.customer_id
JOIN order_item oi ON oi.order_id = o.id
JOIN product p ON p.id = oi.product_id
ORDER BY o.id, p.name;
