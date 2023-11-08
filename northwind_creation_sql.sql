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
  `category_id` SMALLINT NOT NULL,
  `category_name` VARCHAR(15) NOT NULL,
  `description` TEXT NULL DEFAULT NULL,
  `picture` BLOB NULL DEFAULT NULL,
  PRIMARY KEY (`category_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`customer_demographics`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`customer_demographics` (
  `customer_type_id` CHAR(1) NOT NULL,
  `customer_desc` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`customer_type_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`customers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`customers` (
  `customer_id` CHAR(5) NOT NULL,
  `company_name` VARCHAR(40) NOT NULL,
  `contact_name` VARCHAR(30) NULL DEFAULT NULL,
  `contact_title` VARCHAR(30) NULL DEFAULT NULL,
  `address` VARCHAR(60) NULL DEFAULT NULL,
  `city` VARCHAR(15) NULL DEFAULT NULL,
  `region` VARCHAR(15) NULL DEFAULT NULL,
  `postal_code` VARCHAR(10) NULL DEFAULT NULL,
  `country` VARCHAR(15) NULL DEFAULT NULL,
  `phone` VARCHAR(24) NULL DEFAULT NULL,
  `fax` VARCHAR(24) NULL DEFAULT NULL,
  PRIMARY KEY (`customer_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`customer_customer_demo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`customer_customer_demo` (
  `customer_id` CHAR(5) NOT NULL,
  `customer_type_id` CHAR(1) NOT NULL,
  PRIMARY KEY (`customer_id`, `customer_type_id`),
  INDEX `customer_type_id` (`customer_type_id` ASC) VISIBLE,
  CONSTRAINT `customer_customer_demo_ibfk_1`
    FOREIGN KEY (`customer_type_id`)
    REFERENCES `northwind`.`customer_demographics` (`customer_type_id`),
  CONSTRAINT `customer_customer_demo_ibfk_2`
    FOREIGN KEY (`customer_id`)
    REFERENCES `northwind`.`customers` (`customer_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`region`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`region` (
  `region_id` SMALLINT NOT NULL,
  `region_description` VARCHAR(10) NULL DEFAULT NULL,
  PRIMARY KEY (`region_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`territories`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`territories` (
  `territory_id` VARCHAR(20) NOT NULL,
  `territory_description` VARCHAR(30) NULL DEFAULT NULL,
  `region_id` SMALLINT NOT NULL,
  PRIMARY KEY (`territory_id`),
  INDEX `region_id` (`region_id` ASC) VISIBLE,
  CONSTRAINT `territories_ibfk_1`
    FOREIGN KEY (`region_id`)
    REFERENCES `northwind`.`region` (`region_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`employees`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`employees` (
  `employee_id` SMALLINT NOT NULL,
  `last_name` VARCHAR(20) NOT NULL,
  `first_name` VARCHAR(10) NOT NULL,
  `title` VARCHAR(30) NULL DEFAULT NULL,
  `title_of_courtesy` VARCHAR(25) NULL DEFAULT NULL,
  `birth_date` DATE NULL DEFAULT NULL,
  `hire_date` DATE NULL DEFAULT NULL,
  `address` VARCHAR(60) NULL DEFAULT NULL,
  `city` VARCHAR(15) NULL DEFAULT NULL,
  `region` VARCHAR(15) NULL DEFAULT NULL,
  `postal_code` VARCHAR(10) NULL DEFAULT NULL,
  `country` VARCHAR(15) NULL DEFAULT NULL,
  `home_phone` VARCHAR(24) NULL DEFAULT NULL,
  `extension` VARCHAR(4) NULL DEFAULT NULL,
  `photo` BLOB NULL DEFAULT NULL,
  `notes` TEXT NULL DEFAULT NULL,
  `reports_to` SMALLINT NULL DEFAULT NULL,
  `photo_path` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`employee_id`),
  INDEX `reports_to` (`reports_to` ASC) VISIBLE,
  CONSTRAINT `employees_ibfk_1`
    FOREIGN KEY (`reports_to`)
    REFERENCES `northwind`.`employees` (`employee_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`employee_territories`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`employee_territories` (
  `employee_id` SMALLINT NOT NULL,
  `territory_id` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`employee_id`, `territory_id`),
  INDEX `territory_id` (`territory_id` ASC) VISIBLE,
  CONSTRAINT `employee_territories_ibfk_1`
    FOREIGN KEY (`territory_id`)
    REFERENCES `northwind`.`territories` (`territory_id`),
  CONSTRAINT `employee_territories_ibfk_2`
    FOREIGN KEY (`employee_id`)
    REFERENCES `northwind`.`employees` (`employee_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`suppliers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`suppliers` (
  `supplier_id` SMALLINT NOT NULL,
  `company_name` VARCHAR(40) NOT NULL,
  `contact_name` VARCHAR(30) NULL DEFAULT NULL,
  `contact_title` VARCHAR(30) NULL DEFAULT NULL,
  `address` VARCHAR(60) NULL DEFAULT NULL,
  `city` VARCHAR(15) NULL DEFAULT NULL,
  `region` VARCHAR(15) NULL DEFAULT NULL,
  `postal_code` VARCHAR(10) NULL DEFAULT NULL,
  `country` VARCHAR(15) NULL DEFAULT NULL,
  `phone` VARCHAR(24) NULL DEFAULT NULL,
  `fax` VARCHAR(24) NULL DEFAULT NULL,
  `homepage` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`supplier_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`products`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`products` (
  `product_id` SMALLINT NOT NULL,
  `product_name` VARCHAR(40) NOT NULL,
  `supplier_id` SMALLINT NULL DEFAULT NULL,
  `category_id` SMALLINT NULL DEFAULT NULL,
  `quantity_per_unit` VARCHAR(20) NULL DEFAULT NULL,
  `unit_price` DECIMAL(10,2) NULL DEFAULT NULL,
  `units_in_stock` SMALLINT NULL DEFAULT NULL,
  `units_on_order` SMALLINT NULL DEFAULT NULL,
  `reorder_level` SMALLINT NULL DEFAULT NULL,
  `discontinued` INT NOT NULL,
  PRIMARY KEY (`product_id`),
  INDEX `category_id` (`category_id` ASC) VISIBLE,
  INDEX `supplier_id` (`supplier_id` ASC) VISIBLE,
  CONSTRAINT `products_ibfk_1`
    FOREIGN KEY (`category_id`)
    REFERENCES `northwind`.`categories` (`category_id`),
  CONSTRAINT `products_ibfk_2`
    FOREIGN KEY (`supplier_id`)
    REFERENCES `northwind`.`suppliers` (`supplier_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`shippers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`shippers` (
  `shipper_id` SMALLINT NOT NULL,
  `company_name` VARCHAR(40) NOT NULL,
  `phone` VARCHAR(24) NULL DEFAULT NULL,
  PRIMARY KEY (`shipper_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`orders` (
  `order_id` SMALLINT NOT NULL,
  `customer_id` CHAR(5) NULL DEFAULT NULL,
  `employee_id` SMALLINT NULL DEFAULT NULL,
  `order_date` DATE NULL DEFAULT NULL,
  `required_date` DATE NULL DEFAULT NULL,
  `shipped_date` DATE NULL DEFAULT NULL,
  `ship_via` SMALLINT NULL DEFAULT NULL,
  `freight` DECIMAL(10,2) NULL DEFAULT NULL,
  `ship_name` VARCHAR(40) NULL DEFAULT NULL,
  `ship_address` VARCHAR(60) NULL DEFAULT NULL,
  `ship_city` VARCHAR(15) NULL DEFAULT NULL,
  `ship_region` VARCHAR(15) NULL DEFAULT NULL,
  `ship_postal_code` VARCHAR(10) NULL DEFAULT NULL,
  `ship_country` VARCHAR(15) NULL DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  INDEX `customer_id` (`customer_id` ASC) VISIBLE,
  INDEX `employee_id` (`employee_id` ASC) VISIBLE,
  INDEX `ship_via` (`ship_via` ASC) VISIBLE,
  CONSTRAINT `orders_ibfk_1`
    FOREIGN KEY (`customer_id`)
    REFERENCES `northwind`.`customers` (`customer_id`),
  CONSTRAINT `orders_ibfk_2`
    FOREIGN KEY (`employee_id`)
    REFERENCES `northwind`.`employees` (`employee_id`),
  CONSTRAINT `orders_ibfk_3`
    FOREIGN KEY (`ship_via`)
    REFERENCES `northwind`.`shippers` (`shipper_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`order_details`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`order_details` (
  `order_id` SMALLINT NOT NULL,
  `product_id` SMALLINT NOT NULL,
  `unit_price` DECIMAL(10,2) NOT NULL,
  `quantity` SMALLINT NOT NULL,
  `discount` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`order_id`, `product_id`),
  INDEX `product_id` (`product_id` ASC) VISIBLE,
  CONSTRAINT `order_details_ibfk_1`
    FOREIGN KEY (`product_id`)
    REFERENCES `northwind`.`products` (`product_id`),
  CONSTRAINT `order_details_ibfk_2`
    FOREIGN KEY (`order_id`)
    REFERENCES `northwind`.`orders` (`order_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `northwind`.`us_states`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `northwind`.`us_states` (
  `state_id` SMALLINT NOT NULL,
  `state_name` VARCHAR(100) NULL DEFAULT NULL,
  `state_abbr` CHAR(2) NULL DEFAULT NULL,
  `state_region` VARCHAR(50) NULL DEFAULT NULL,
  PRIMARY KEY (`state_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
