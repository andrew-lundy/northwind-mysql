-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema northwind
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema northwind
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `northwind` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `northwind` ;

-- -----------------------------------------------------
-- Table `northwind`.`categories`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`categories` (
  `category_id` smallint NOT NULL,
  `category_name` varchar(15) NOT NULL,
  `description` text,
  `picture` blob,
  PRIMARY KEY (`category_id`)
)
ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table `northwind`.`customer_demographics`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`customer_demographics` (
  `customer_type_id` char(1) NOT NULL,
  `customer_desc` text,
  PRIMARY KEY (`customer_type_id`)
) 
ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`customers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`customers` (
  `customer_id` char(5) NOT NULL,
  `company_name` varchar(40) NOT NULL,
  `contact_name` varchar(30) DEFAULT NULL,
  `contact_title` varchar(30) DEFAULT NULL,
  `address` varchar(60) DEFAULT NULL,
  `city` varchar(15) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `region` varchar(15) DEFAULT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `country` varchar(15) DEFAULT NULL,
  `phone` varchar(24) DEFAULT NULL,
  `fax` varchar(24) DEFAULT NULL,
  PRIMARY KEY (`customer_id`)) 
ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`customer_customer_demo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`customer_customer_demo` (
  `customer_id` char(5) NOT NULL,
  `customer_type_id` char(1) NOT NULL,
  PRIMARY KEY (`customer_id`,`customer_type_id`),
  INDEX `customer_type_id` (`customer_type_id` ASC) VISIBLE,
  CONSTRAINT `customer_customer_demo_ibfk_1` 
    FOREIGN KEY (`customer_type_id`) 
    REFERENCES `northwind`.`customer_demographics` (`customer_type_id`),
  CONSTRAINT `customer_customer_demo_ibfk_2` 
    FOREIGN KEY (`customer_id`) 
    REFERENCES `northwind`.`customers_temp` (`customer_id`)) 
ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`region`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`region` (
  `region_id` smallint NOT NULL,
  `region_name` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`region_id`)) 
ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`territories`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`territories` (
  `territory_id` varchar(20) NOT NULL,
  `territory_description` varchar(30) DEFAULT NULL,
  `region_id` smallint NOT NULL,
  PRIMARY KEY (`territory_id`),
  INDEX `region_id` (`region_id` ASC) VISIBLE,
  CONSTRAINT `territories_ibfk_1` 
    FOREIGN KEY (`region_id`) 
    REFERENCES `northwind`.`region` (`region_id`)) 
ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`employees`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`employees` (
  `employee_id` smallint NOT NULL,
  `last_name` varchar(20) NOT NULL,
  `first_name` varchar(20) NOT NULL,
  `title` varchar(30) DEFAULT NULL,
  `title_of_courtesy` varchar(25) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `hire_date` date DEFAULT NULL,
  `address` varchar(60) DEFAULT NULL,
  `city` varchar(15) DEFAULT NULL,
  `state` varchar(15) DEFAULT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `country` varchar(15) DEFAULT NULL,
  `region` smallint DEFAULT NULL,
  `home_phone` varchar(24) DEFAULT NULL,
  `extension` varchar(4) DEFAULT NULL,
  `photo` blob,
  `notes` text,
  `reports_to` smallint DEFAULT NULL,
  `photo_path` varchar(400) DEFAULT NULL,
  PRIMARY KEY (`employee_id`)) 
ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table `northwind`.`employee_territories`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`employee_territories` (
  `employee_id` smallint NOT NULL,
  `territory_id` varchar(20) NOT NULL,
  PRIMARY KEY (`employee_id`,`territory_id`),
  INDEX `territory_id` (`territory_id` ASC) VISIBLE,
  CONSTRAINT `employee_territories_ibfk_1` 
    FOREIGN KEY (`territory_id`) 
    REFERENCES `northwind`.`territories` (`territory_id`),
  CONSTRAINT `employee_territories_ibfk_2` 
    FOREIGN KEY (`employee_id`) 
    REFERENCES `northwind`.`employees` (`employee_id`)) 
ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table `northwind`.`suppliers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`suppliers` (
  `supplier_id` smallint NOT NULL,
  `company_name` varchar(40) NOT NULL,
  `contact_name` varchar(30) DEFAULT NULL,
  `contact_title` varchar(30) DEFAULT NULL,
  `address` varchar(60) DEFAULT NULL,
  `city` varchar(15) DEFAULT NULL,
  `region` varchar(15) DEFAULT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `country` varchar(15) DEFAULT NULL,
  `phone` varchar(24) DEFAULT NULL,
  `fax` varchar(24) DEFAULT NULL,
  `homepage` text,
  PRIMARY KEY (`supplier_id`)) 
ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table `northwind`.`products`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`products` (
  `product_id` smallint NOT NULL,
  `product_name` varchar(40) NOT NULL,
  `supplier_id` smallint DEFAULT NULL,
  `category_id` smallint DEFAULT NULL,
  `quantity_per_unit` varchar(20) DEFAULT NULL,
  `unit_price` decimal(10,2) DEFAULT NULL,
  `units_in_stock` smallint DEFAULT NULL,
  `units_on_order` smallint DEFAULT NULL,
  `reorder_level` smallint DEFAULT NULL,
  `discontinued` int NOT NULL,
  PRIMARY KEY (`product_id`),
  INDEX `category_id` (`category_id` ASC) VISIBLE,
  INDEX `supplier_id` (`supplier_id`) VISIBLE,
  CONSTRAINT `products_ibfk_1` 
    FOREIGN KEY (`category_id`) 
    REFERENCES `northwind`.`categories` (`category_id`),
  CONSTRAINT `products_ibfk_2` 
    FOREIGN KEY (`supplier_id`) 
    REFERENCES `northwind`.`suppliers` (`supplier_id`)) 
ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Table `northwind`.`shippers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`shippers` (
  `shipper_id` smallint NOT NULL,
  `company_name` varchar(40) NOT NULL,
  `phone` varchar(24) DEFAULT NULL,
  PRIMARY KEY (`shipper_id`)) 
ENGINE=InnoDB DEFAULT 
CHARSET=utf8mb4 
COLLATE=utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`orders` (
  `order_id` smallint NOT NULL,
  `customer_id` char(5) DEFAULT NULL,
  `employee_id` smallint DEFAULT NULL,
  `order_date` date DEFAULT NULL,
  `required_date` date DEFAULT NULL,
  `shipped_date` date DEFAULT NULL,
  `ship_via` smallint DEFAULT NULL,
  `freight` decimal(10,2) DEFAULT NULL,
  `ship_name` varchar(40) DEFAULT NULL,
  `ship_address` varchar(60) DEFAULT NULL,
  `ship_city` varchar(15) DEFAULT NULL,
  `ship_state` varchar(100) DEFAULT NULL,
  `ship_region` smallint DEFAULT NULL,
  `ship_postal_code` varchar(10) DEFAULT NULL,
  `ship_country` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  INDEX `customer_id` (`customer_id` ASC) VISIBLE,
  INDEX `ship_via` (`ship_via` ASC) VISIBLE,
  INDEX `orders_ibfk_2` (`employee_id` ASC) VISIBLE,
  CONSTRAINT `orders_ibfk_1` 
    FOREIGN KEY (`customer_id`) 
    REFERENCES `northwind`.`customers` (`customer_id`),
  CONSTRAINT `orders_ibfk_2` 
    FOREIGN KEY (`employee_id`) 
    REFERENCES `northwind`.`employees` (`employee_id`),
  CONSTRAINT `orders_ibfk_3` 
    FOREIGN KEY (`ship_via`) 
    REFERENCES `northwind`.`shippers` (`shipper_id`))
ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`order_details`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`order_details` (
  `order_id` smallint NOT NULL,
  `product_id` smallint NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `quantity` smallint NOT NULL,
  `discount` decimal(10,2) NOT NULL,
  PRIMARY KEY (`order_id`,`product_id`),
  INDEX `product_id` (`product_id` ASC) VISIBLE,
  CONSTRAINT `order_details_ibfk_1` 
    FOREIGN KEY (`product_id`) 
    REFERENCES `northwind`.`products` (`product_id`),
  CONSTRAINT `order_details_ibfk_2` 
    FOREIGN KEY (`order_id`) 
    REFERENCES `northwind`.`orders` (`order_id`)) 
ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`us_states`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`us_states` (
  `state_id` smallint NOT NULL,
  `state_name` varchar(100) DEFAULT NULL,
  `state_abbr` char(2) DEFAULT NULL,
  `state_region` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`state_id`)) 
ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_0900_ai_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;