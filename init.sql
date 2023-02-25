
-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `mydb` ;

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`category`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`category` ;

CREATE TABLE IF NOT EXISTS `mydb`.`category` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `unique_fabric` UNIQUE (`name`)
  )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`fabric`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`fabric` ;

CREATE TABLE IF NOT EXISTS `mydb`.`fabric` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `category_id` INT NOT NULL,
  `category` VARCHAR(45) NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  `valid` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  INDEX `fk_fabric_category1_idx` (`category_id` ASC),
  CONSTRAINT `fk_fabric_category1`
    FOREIGN KEY (`category_id`)
    REFERENCES `mydb`.`category` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `unique_fabric` UNIQUE (`name`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`pattern`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`pattern` ;

CREATE TABLE IF NOT EXISTS `mydb`.`pattern` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`fabric_pattern`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`fabric_pattern` ;

CREATE TABLE IF NOT EXISTS `mydb`.`fabric_pattern` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `fabric_id` INT NOT NULL,
  `pattern_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_fabric_pattern_fabric1_idx` (`fabric_id` ASC)
  INDEX `fk_fabric_pattern_pattern1_idx` (`pattern_id` ASC),
  CONSTRAINT `fk_fabric_pattern_fabric1`
    FOREIGN KEY (`fabric_id`)
    REFERENCES `mydb`.`fabric` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_fabric_pattern_pattern1`
    FOREIGN KEY (`pattern_id`)
    REFERENCES `mydb`.`pattern` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `unique_pattern`
    UNIQUE (`fabric_id`, `pattern_id`)
    )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`material`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`material` ;

CREATE TABLE IF NOT EXISTS `mydb`.`material` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`fabric_material`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`fabric_material` ;

CREATE TABLE IF NOT EXISTS `mydb`.`fabric_material` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `fabric_id` INT NOT NULL,
  `material_id` INT NOT NULL,
  `percentage` DECIMAL(5,2) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_fabric_mixed_rate_fabric1_idx` (`fabric_id` ASC),
  INDEX `fk_fabric_mixed_rate_mixed_rate1_idx` (`material_id` ASC),
  CONSTRAINT `fk_fabric_mixed_rate_fabric1`
    FOREIGN KEY (`fabric_id`)
    REFERENCES `mydb`.`fabric` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_fabric_mixed_rate_mixed_rate1`
    FOREIGN KEY (`material_id`)
    REFERENCES `mydb`.`material` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `unique_material`
    UNIQUE (`fabric_id`, `material_id`)
    )
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


-- -----------------------------------------------------
-- Triggers
-- -----------------------------------------------------

drop trigger IF EXISTS `mydb`.`tr_material_validation_after_insert`;

DELIMITER $$
CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`tr_material_validation_after_insert`
AFTER INSERT ON fabric_material FOR EACH ROW
BEGIN
	IF 
		(SELECT SUM(percentage)
		FROM fabric_material
		where fabric_id = NEW.fabric_id) = 100.00
	THEN
		UPDATE fabric SET valid = 1 WHERE fabric.id = NEW.fabric_id;
	ELSE
		UPDATE fabric SET valid = 0 WHERE fabric.id = NEW.fabric_id;
	END IF;
END $$
DELIMITER ;

drop trigger IF EXISTS `mydb`.`tr_material_validation_after_update`;

DELIMITER $$
CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`tr_material_validation_after_update`
AFTER UPDATE ON fabric_material FOR EACH ROW
BEGIN
	IF 
		(SELECT SUM(percentage)
		FROM fabric_material
		where fabric_id = NEW.fabric_id) = 100.00
	THEN
		UPDATE fabric SET valid = 1 WHERE fabric.id = NEW.fabric_id;
	ELSE
		UPDATE fabric SET valid = 0 WHERE fabric.id = NEW.fabric_id;
	END IF;
END $$
DELIMITER ;

drop trigger IF EXISTS `mydb`.`tr_material_validation_before_delete`;

DELIMITER $$
CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`tr_material_validation_before_delete`
AFTER DELETE ON fabric_material FOR EACH ROW
BEGIN
	IF 
		(SELECT SUM(percentage)
		FROM fabric_material
		where fabric_id = OLD.fabric_id) = 100.00
	THEN
		UPDATE fabric SET valid = 1 WHERE fabric.id = OLD.fabric_id;
	ELSE
		UPDATE fabric SET valid = 0 WHERE fabric.id = OLD.fabric_id;
	END IF;
END $$
DELIMITER ;

drop trigger IF EXISTS `mydb`.`tr_category_name_after_update`;

DELIMITER $$
CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`tr_category_name_after_update`
AFTER UPDATE ON category FOR EACH ROW
BEGIN
		UPDATE fabric SET category = NEW.name WHERE category_id = NEW.id;
END $$
DELIMITER ;
