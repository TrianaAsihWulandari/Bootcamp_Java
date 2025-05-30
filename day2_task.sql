set search_path to oe,hr;

--Task 1
---Create table & relasinya untuk table bank,users,carts,cart_items & attribute tambahan yang ada di table
---orders.

create table oe.bank (

    bank_code varchar(4) primary key,
    bank_name varchar(55) not null
);
alter table oe.orders
 add column user_id integer,
 add constraint user_id_fk foreign key (user_id) references oe.users(user_id),
 add column bank_code varchar(4),
 add constraint bank_code_fk foreign key (bank_code) references oe.bank(bank_code),
 add column total_discount decimal(5,2),
 add column total_amount decimal(8,2),
 add column payment_type varchar(15),
 add column card_no varchar(25),
 add column transac_no varchar(25),
 add column transac_date timestamp,
 add column ref_no varchar(25);

select * from oe.bank
select * from oe.orders


create table oe.users (
    user_id int primary key,
    user_name varchar(15) not null,
    user_email varchar(80) unique not null ,
    user_password varchar(125) not null,
    user_handphone varchar(15) unique not null,
    created_on timestamp default current_timestamp

);

select * from oe.users


create table oe.carts (
    cart_id smallint primary key,
    created_on timestamp default current_timestamp,
    user_id int unique not null
);

alter table  oe.users
add constraint fk_users_cart foreign key (user_id) 
references oe.users(user_id)
on update cascade on delete cascade


select u.user_name, c.cart_id from oe.users u
join oe.carts c on u.user_id = c.user_id

select * from oe.carts
select * from oe.users


create table oe.cart_items (
    cart_item_id smallint primary key,
    product_id int unique not null,
    quantity smallint not null,
    created_on timestamp default current_timestamp,
    cart_id int not null
);

alter table  oe.carts
add constraint fk_cart_item_cart foreign key (cart_id) 
references oe.carts(cart_id);

alter table  oe.carts_items
add constraint fk_cart_product_id foreign key (product_id) 
references oe.products(product_id);


select * from oe.cart_items

--Task 2
---Buat link antara table hr.locations dan table oe.orders, dan update kolom location_id di table oe.orders.

alter table  oe.carts_items
add constraint fk_cart_product_id foreign key (product_id) 
references oe.products(product_id);

alter table oe.orders
add column location_id int,

alter table  hr.locations
add constraint location_id_hr foreign key (location_id) 
references hr.locations(location_id);


update oe.orders as cu
set location_id = (select location_id from oe.location_x loc
where loc.street_address=cu.ship_address and loc.postal_code=cu.ship_postal_code
and loc.city=cu.ship_city and loc.state_province=cu.ship_region and
loc.country_name=cu.ship_country
) where cu.location_id is null

select * from oe.orders where location_id is not null
select * from oe.location_x



--Task 3
---Pindahkan data employee dari schema oe.employees ke schema hr.employees. Data yang dipindahkan
---cukup mengikuti kolom yang ada di schema hr.employees.

insert into hr.employees (employee_id, first_name, last_name, email, hire_date, job_id, salary)
select employee_id, first_name, last_name, LOWER(first_name||  '.' || last_name || '@sqltutorial.com')
as email, hire_date, j.job_id,
0.00 as salary
from oe.employees
JOIN (
    SELECT job_id
    FROM hr.jobs
    ORDER BY RANDOM()
	limit 1
) j ON TRUE;

select * from hr.employees

---Buat relasi antara table hr.employees dengan table oe.orders

alter table  oe.orders
add constraint fk_order_employee_id foreign key (employee_id) 
references hr.orders(employee_id);


select *  from oe.orders


--Task 4
---Create table users di shema oe.
ada pada no 1

select * from oe.users

---Pindahkan data dari table oe.customers ke table users.

CREATE EXTENSION IF NOT EXISTS pgcrypto;


insert into oe.users (user_name,user_password,user_handphone) select contact_name as user_name, 
crypt(lower(oc.customer_id), gen_salt('bf', 12)),
phone as user_handphone from oe.customers oc

---Buat relasi antara table oe.users dengan table oe.orders

alter table oe.users
alter column user_id add generated by default as identity


select * from oe.users




--cara untuk mengatasi masalah panjang data
alter table oe.users
alter column user_name type varchar(30),
alter column user_handphone type varchar(24)

--cara mengatasi kolom user_email not null agar null
ALTER TABLE users ALTER COLUMN user_email DROP NOT NULL;
