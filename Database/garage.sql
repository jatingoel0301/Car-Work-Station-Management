-- phpMyAdmin SQL Dump
-- version 4.8.0.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 23, 2018 at 11:22 AM
-- Server version: 10.1.32-MariaDB
-- PHP Version: 7.2.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `garage`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `at_least_one_num` (IN `A` INT, IN `B` INT, IN `C` INT, OUT `D` INT)  BEGIN
if((A is null) and (B is null) and (C is null))
then SET D=-1;
elseif((A is not null and (A<0 or length(A)<>8))or(B is not null and (B<0 or length(B)<>8))or(C is not null and (C<0 or (length(C)<>10))))
then set D=-2;
else
	SET D=1;
end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `remarks_road_test` (IN `a` VARCHAR(7), IN `b` VARCHAR(11))  BEGIN

if(lower(a)='fit') THEN
update works_on_vehicle set  completion_date=CURRENT_TIMESTAMP() where comp_id=b;
update works_on_vehicle set STATUS='complete' where comp_id=b;
else
insert into road_test(car_no,comp_id,date_of_road_test,emp_id,km_out,remarks,road_test_scheduled,test_id)
values("AR-17 8789",b,NULL,'E1',4,NULL,2);
end if;
end$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `cal_bill` (`a` VARCHAR(20), `b` VARCHAR(11), `c` DATETIME) RETURNS INT(11) BEGIN
 DECLARE done INT DEFAULT FALSE;
declare amn int;
declare x int;
declare rec int;
declare c1 cursor for select amount from comp_part where complaint_id=a;

declare c3 cursor for select amount from insurance_claim where car_no=b and claim_date=c;
DECLARE c4 cursor for select amount from car_annual_service where car_no=b and comp_id=a;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
set x = 0;
open c1;
read_loop:loop
fetch c1 into rec;
IF done THEN
 LEAVE read_loop;
  END IF;
set x=x+rec;
end loop;
close c1;

open c3;
read_loop:loop
fetch c3 into rec;
IF done THEN
 LEAVE read_loop;
  END IF;
set x=x+rec;
end loop;
close c3;
open c4;
read_loop:loop
fetch c4 into rec;
IF done THEN
 LEAVE read_loop;
  END IF;
set x=x+rec;
end loop;
close c4;

set amn =x;

return(amn);
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `bill`
--

CREATE TABLE `bill` (
  `bill_no` varchar(12) NOT NULL,
  `customer_id` varchar(11) DEFAULT NULL,
  `car_no` varchar(12) DEFAULT NULL,
  `complaint_id` varchar(20) NOT NULL,
  `bill_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `delay_in_delivery` int(11) DEFAULT NULL,
  `delay_discount` int(11) DEFAULT NULL,
  `total_amount_to_be_paid` int(11) NOT NULL,
  `completion_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `bill`
--

INSERT INTO `bill` (`bill_no`, `customer_id`, `car_no`, `complaint_id`, `bill_date`, `delay_in_delivery`, `delay_discount`, `total_amount_to_be_paid`, `completion_date`) VALUES
('B00000100000', NULL, NULL, 'C1', '2017-08-25 11:55:20', NULL, NULL, 0, NULL),
('B00000100001', NULL, NULL, 'C2', '2017-08-25 11:55:30', NULL, NULL, 0, NULL),
('B00000100002', NULL, NULL, 'C3', '2017-08-25 11:55:39', NULL, NULL, 0, NULL),
('B00000100003', NULL, '', 'C1', '2018-08-18 11:58:33', NULL, NULL, 0, NULL);

--
-- Triggers `bill`
--
DELIMITER $$
CREATE TRIGGER `tbill_before_insert` BEFORE INSERT ON `bill` FOR EACH ROW Begin
declare a varchar(12);
select max(bill_no) into a from bill order by bill_no desc limit 1;
if(a is null) then
 set new.bill_no=concat('B',LPAD(100000,11,'0'));
ELSE
 set new.bill_no=concat('B',lpad(cast(trim(leading 'B' from a) as int)+1,11,'0'));
 end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tbill_before_update` BEFORE UPDATE ON `bill` FOR EACH ROW Begin
set new.total_amount_to_be_paid=cal_bill(new.complaint_ID,new.car_no,new.bill_date);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `car_annual_service`
--

CREATE TABLE `car_annual_service` (
  `service_no` int(11) NOT NULL,
  `car_no` varchar(12) NOT NULL,
  `last_service_date` datetime DEFAULT NULL,
  `current_service_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `next_service_date` datetime NOT NULL,
  `km_travelled` int(11) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `comp_id` varchar(20) NOT NULL,
  `status` varchar(8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `car_annual_service`
--

INSERT INTO `car_annual_service` (`service_no`, `car_no`, `last_service_date`, `current_service_date`, `next_service_date`, `km_travelled`, `amount`, `comp_id`, `status`) VALUES
(1, 'AR-07 12345', NULL, '2017-08-20 21:42:55', '2018-02-20 21:42:55', 50, 5000, 'C1', 'complete'),
(1, 'AR-17 8789', NULL, '2017-08-20 21:43:04', '2018-02-20 21:43:04', 10, 5000, 'C2', 'complete'),
(1, 'CG-011234', NULL, '2017-08-23 19:57:32', '2018-02-23 19:57:32', 5, 5000, 'C3', 'complete');

--
-- Triggers `car_annual_service`
--
DELIMITER $$
CREATE TRIGGER `comp_date_annual_after_update` AFTER UPDATE ON `car_annual_service` FOR EACH ROW BEGIN
declare a int;
declare b int;
declare c int;
declare d int;
select count(*) into a from specific_complaints where complaint_id=(new.comp_id) and lower(status)='complete';
select count(*) into b from specific_complaints where complaint_id=(new.comp_id);
select count(*) into c from comp_predefined where comp_id=(new.comp_id) and lower(status)='complete';
select count(*) into d from comp_predefined where comp_id=(new.comp_id);
if (a=b and c=d and lower(new.status)='complete') then
insert into road_test(comp_id,km_out,road_test_scheduled) values(new.comp_id,5,DATE_ADD(CURRENT_TIMESTAMP(),INTERVAL 1 day));
end if;                                                              
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `last_next_insert` BEFORE INSERT ON `car_annual_service` FOR EACH ROW Begin 
declare a datetime;
declare b int;
declare c datetime;
declare d varchar(11);
Declare s datetime;
Declare r datetime;
select car_no into d from works_on_vehicle where comp_id=new.comp_id;
set new.car_no=d;
if(new.car_no is null) THEN
signal SQLSTATE '45000'
set MESSAGE_TEXT='First Register complaint';
end if;
set new.current_service_Date = CURRENT_TIMESTAMP();
select max(next_service_date) into a from car_annual_service where car_no=(new.car_no);
if(new.current_service_date<a) then
signal sqlstate '45000'
set MESSAGE_TEXT ='Service is not due';
end if;
select max(current_service_date) into a from car_annual_service where car_no=(new.car_no);
set new.last_service_Date = a;
set new.next_service_date= DATE_ADD(new.current_Service_Date,INTERVAL 6 MONTH);
select max(service_no)+1 into b from car_Annual_Service where car_no=new.car_no;
set new.service_no = b;
if(new.service_no is null) then
set new.service_no=1;
end if;
set new.amount=5000+((new.service_no-1)*500);
select received_date into a from works_on_vehicle where comp_id=new.comp_id and car_no=new.car_no;
if((a>new.current_service_Date)) THEN
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT = 'Invalid date';
end if;
set new.status='pending';

SELECT estimated_completion_date,received_date into s,r from works_on_vehicle where comp_id=new.comp_id;
if(s is null) THEN
update works_on_vehicle set estimated_completion_date=Date_ADD(r,interval 2 day) where comp_id=new.comp_id;
ELSE
update works_on_vehicle set estimated_completion_date=Date_ADD(s,interval 1 day) where comp_id=new.comp_id; 
end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `last_next_update` BEFORE UPDATE ON `car_annual_service` FOR EACH ROW Begin 
declare a datetime;
declare b int;
declare c datetime;
declare d varchar(11);
select car_no into d from works_on_vehicle where comp_id=new.comp_id;
set new.car_no=d;
select received_date into a from works_on_vehicle where comp_id=new.comp_id and car_no=new.car_no;
if((a>new.current_service_Date)) THEN
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT = 'Invalid date';
end if;
if(lower(new.status)!='complete') then
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT = 'Status can only be complete or pending';
end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `comp_part`
--

CREATE TABLE `comp_part` (
  `complaint_id` varchar(20) NOT NULL,
  `part_id` varchar(11) NOT NULL,
  `qty_fitted` int(11) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Triggers `comp_part`
--
DELIMITER $$
CREATE TRIGGER `parts_insert` BEFORE INSERT ON `comp_part` FOR EACH ROW BEGIN
DECLARE a int;
if(new.qty_fitted<1) THEN
signal SQLSTATE '45000'
set MESSAGE_TEXT='Quantity should be greater than zero';
end if;
SELECT amount_Sold_for into a from spare_parts where part_id=new.part_id;
set new.amount=a;
update spare_parts set qty_left=qty_left-new.qty_fitted where part_id =new.part_id;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `parts_update_comp_before` BEFORE UPDATE ON `comp_part` FOR EACH ROW BEGIN
if(new.qty_fitted<1) THEN
signal SQLSTATE '45000'
set MESSAGE_TEXT='Quantity should be greater than zero';
end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `comp_predefined`
--

CREATE TABLE `comp_predefined` (
  `comp_id` varchar(30) NOT NULL,
  `job_id` varchar(12) NOT NULL,
  `status` varchar(8) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Triggers `comp_predefined`
--
DELIMITER $$
CREATE TRIGGER `comp_date_predefined_after_update` AFTER UPDATE ON `comp_predefined` FOR EACH ROW BEGIN
declare a int;
declare b int;
declare c varchar(8);
DEClare d int;
declare e int;
select count(*) into a from specific_complaints where complaint_id=(new.comp_id) and lower(status)='complete';
select count(*) into b from specific_complaints where complaint_id=(new.comp_id);
select count(*) into d from comp_predefined where comp_id=(new.comp_id) and lower(status)='complete';
select count(*) into e from comp_predefined where comp_id=(new.comp_id);
select status into c from car_annual_service where comp_id=(new.comp_id);
if (a=b and d=e and (c=lower('complete') or c is null) ) then
insert into road_test(comp_id,km_out,road_test_scheduled) values(new.comp_id,5,DATE_ADD(CURRENT_TIMESTAMP(),INTERVAL 1 day));
end if;                                                              
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `predefined_days_after_insert` AFTER INSERT ON `comp_predefined` FOR EACH ROW BEGIN
Declare s datetime;
Declare r datetime;
Declare d int;
select days_required into d from predefinedjobs where job_id=new.job_id;
SELECT estimated_completion_date,received_date into s,r from works_on_vehicle where comp_id=new.comp_id;
if(s is null) THEN
update works_on_vehicle set estimated_completion_date=Date_ADD(r,interval d+1 day) where comp_id=new.comp_id;
ELSE
update works_on_vehicle set estimated_completion_date=Date_ADD(s,interval d day) where comp_id=new.comp_id; 
end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `predefined_relation` BEFORE INSERT ON `comp_predefined` FOR EACH ROW BEGIN
set new.status='Pending';
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `customer_id` varchar(11) NOT NULL,
  `customer_name` varchar(30) DEFAULT NULL,
  `address` varchar(30) DEFAULT NULL,
  `tel_no_o` bigint(10) DEFAULT NULL,
  `tel_no_r` bigint(10) DEFAULT NULL,
  `mobile_no` bigint(10) DEFAULT NULL,
  `email_id` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`customer_id`, `customer_name`, `address`, `tel_no_o`, `tel_no_r`, `mobile_no`, `email_id`) VALUES
('C1', 'Jatin Goel', NULL, NULL, NULL, 9123456789, NULL),
('C2', 'Rahul', NULL, 12345678, NULL, NULL, NULL);

--
-- Triggers `customer`
--
DELIMITER $$
CREATE TRIGGER `atleast_one_num_insert` BEFORE INSERT ON `customer` FOR EACH ROW begin
declare d int;
declare a varchar(12);
select max(customer_id) into a from customer order by customer_id desc limit 1;
if(a is null) then
 set new.customer_id='C1';
ELSE
 set new.customer_id=concat('C',(cast(trim(leading 'C' from a) as int)+1));
 end if;
 if(new.customer_NAME is null) then
 SIGNAL SQLSTATE '20002'
 set MESSAGE_TEXT = 'Please enter name of the customer';
 end if;
call at_least_one_num(new.tel_no_o,new.tel_no_r,new.mobile_no,d);
if(d = -1) then
SIGNAL SQLSTATE '20001'
set MESSAGE_TEXT = 'Please provide atleast one of the contact numbers';
elseif(d=-2) then
SIGNAL SQLSTATE '20002'
set MESSAGE_TEXT = 'One(or more) of the numbers is incorrect';
end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `atleast_one_num_update` BEFORE UPDATE ON `customer` FOR EACH ROW begin
declare d int;
declare a varchar(12);
select max(customer_id) into a from customer order by customer_id desc limit 1;
if(a is null) then
 set new.customer_id='C1';
ELSE
 set new.customer_id=concat('C',(cast(trim(leading 'C' from a) as int)+1));
 end if;
 if(new.customer_NAME is null) then
 SIGNAL SQLSTATE '20002'
 set MESSAGE_TEXT = 'Please enter name of the customer';
 end if;
call at_least_one_num(new.tel_no_o,new.tel_no_r,new.mobile_no,d);
if(d = -1) then
SIGNAL SQLSTATE '20001'
set MESSAGE_TEXT = 'Please provide atleast one of the contact numbers';
elseif(d=-2) then
SIGNAL SQLSTATE '20002'
set MESSAGE_TEXT = 'One(or more) of the numbers is incorrect';
end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `district`
--

CREATE TABLE `district` (
  `Discode` varchar(5) NOT NULL,
  `Jurisdiction` varchar(30) NOT NULL,
  `state` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `district`
--

INSERT INTO `district` (`Discode`, `Jurisdiction`, `state`) VALUES
('AN-01', 'Port Blair', 'Andaman and Nicobar Islands'),
('AN-02', 'CAR-Nicobar', 'Andaman and Nicobar Islands'),
('AR-01', 'Itanagar', 'Arunchal Paradesh'),
('AR-02', 'Itanagar', 'Arunchal Paradesh'),
('AR-03', 'Tawang', 'Arunchal Paradesh'),
('AR-04', 'Bomdila', 'Arunchal Paradesh'),
('AR-05', 'Seppa', 'Arunchal Paradesh'),
('AR-06', 'Ziro', 'Arunchal Paradesh'),
('AR-07', 'Daporijo', 'Arunchal Paradesh'),
('AR-08', 'Along', 'Arunchal Paradesh'),
('AR-09', 'Pasighat', 'Arunchal Paradesh'),
('AR-10', 'Anini', 'Arunchal Paradesh'),
('AR-11', 'Tezu', 'Arunchal Paradesh'),
('AR-12', 'Changlang', 'Arunchal Paradesh'),
('AR-13', 'Khonsa', 'Arunchal Paradesh'),
('AR-14', 'Yingkiong', 'Arunchal Paradesh'),
('AR-15', 'Koloriang', 'Arunchal Paradesh'),
('AR-16', 'Roing', 'Arunchal Paradesh'),
('AR-17', 'Hawai', 'Arunchal Paradesh'),
('AR-20', 'Namsai', 'Arunchal Paradesh'),
('CG-01', 'Governor of Chhattisgarh', 'Chattishgrah'),
('CG-02', 'Government of Chhattisgarh', 'Chattishgrah'),
('CG-03', 'Chhattisgarh Police', 'Chattishgrah'),
('CG-04', 'Raipur', 'Chattishgrah'),
('CG-05', 'Dhamtari', 'Chattishgrah'),
('CG-06', 'Mahasamund', 'Chattishgrah'),
('CG-07', 'Durg', 'Chattishgrah'),
('CG-08', 'Rajnandgaon', 'Chattishgrah'),
('CG-09', 'Kawardha', 'Chattishgrah'),
('CG-10', 'Bilaspur', 'Chattishgrah'),
('CG-11', 'Janjgir', 'Chattishgrah'),
('CG-12', 'Korba', 'Chattishgrah'),
('CG-13', 'Raigarh', 'Chattishgrah'),
('CG-14', 'Jashpur Nagar', 'Chattishgrah'),
('CG-15', 'Ambikapur', 'Chattishgrah'),
('CG-16', 'Baikunthpur', 'Chattishgrah'),
('CG-17', 'Jagdalpur', 'Chattishgrah'),
('CG-18', 'Dantewada', 'Chattishgrah'),
('CG-19', 'Kanker', 'Chattishgrah'),
('CG-20', 'Bijapur', 'Chattishgrah'),
('CG-21', 'Narayanpur', 'Chattishgrah'),
('CG-22', 'Baloda Bazar', 'Chattishgrah'),
('CG-23', 'Gariaband', 'Chattishgrah'),
('CG-24', 'Balod', 'Chattishgrah'),
('CG-25', 'Bemetara', 'Chattishgrah'),
('CG-26', 'Sukma', 'Chattishgrah'),
('CG-27', 'Kondagaon', 'Chattishgrah'),
('CG-28', 'Mungeli', 'Chattishgrah'),
('CG-29', 'Surajpur', 'Chattishgrah'),
('CG-30', 'Balrampur', 'Chattishgrah'),
('CH-01', 'Chandigarh', 'Chandigarh'),
('CH-02', 'Chandigarh', 'Chandigarh'),
('CH-03', 'Chandigarh', 'Chandigarh'),
('CH-04', 'Chandigarh', 'Chandigarh'),
('DD-02', 'Diu', 'Daman and Diu'),
('DD-03', 'Daman', 'Daman and Diu'),
('DL-1', 'Mall Road', 'Delhi'),
('DL-10', 'Raja Garden', 'Delhi'),
('DL-11', 'Rohini', 'Delhi'),
('DL-12', 'Vasant Vihar', 'Delhi'),
('DL-13', 'Surajmal Vihar', 'Delhi'),
('DL-14', 'Sonipat', 'Delhi'),
('DL-15', 'Gurgaon', 'Delhi'),
('DL-16', 'Faridabad', 'Delhi'),
('DL-17', 'Noida', 'Delhi'),
('DL-18', 'Ghaziabad', 'Delhi'),
('DL-2', 'Tilak Marg', 'Delhi'),
('DL-3', 'Sheikh Sarai', 'Delhi'),
('DL-30', 'Noida', 'Delhi'),
('DL-4', 'Janakpuri', 'Delhi'),
('DL-5', 'Loni Road', 'Delhi'),
('DL-6', 'Sarai Kale Khan', 'Delhi'),
('DL-7', 'Mayur Vihar', 'Delhi'),
('DL-8', 'Wazir Pur', 'Delhi'),
('DL-9', 'Janakpuri', 'Delhi'),
('DN-09', 'Silvassa', 'Dadra and Nagar Haveli'),
('GA-01', 'Panajim', 'Goa'),
('GA-02', 'Margao', 'Goa'),
('GA-03', 'Mapusa', 'Goa'),
('GA-04', 'Bicholim', 'Goa'),
('GA-05', 'Ponda', 'Goa'),
('GA-06', 'Vasco da Gama', 'Goa'),
('GA-07', 'Panajim', 'Goa'),
('GA-08', 'Margao', 'Goa'),
('GA-09', 'Quepem', 'Goa'),
('GA-10', 'Canacona', 'Goa'),
('GA-11', 'Pernem', 'Goa'),
('GA-12', 'Dharbandora', 'Goa'),
('GJ-1', 'Ahmedabad', 'Gujarat'),
('GJ-10', 'Jamnagar', 'Gujarat'),
('GJ-11', 'Junagadh', 'Gujarat'),
('GJ-12', 'Bhuj', 'Gujarat'),
('GJ-13', 'Surendranagar', 'Gujarat'),
('GJ-14', 'Rajula', 'Gujarat'),
('GJ-15', 'Valsad', 'Gujarat'),
('GJ-16', 'Bharuch', 'Gujarat'),
('GJ-17', 'Godhra', 'Gujarat'),
('GJ-18', 'Gandhinagar', 'Gujarat'),
('GJ-19', 'Bardoli', 'Gujarat'),
('GJ-2', 'Mehsana', 'Gujarat'),
('GJ-20', 'Dahod', 'Gujarat'),
('GJ-21', 'Navsari', 'Gujarat'),
('GJ-22', 'Rajpipla', 'Gujarat'),
('GJ-23', 'Anand', 'Gujarat'),
('GJ-24', 'Patan', 'Gujarat'),
('GJ-25', 'Porbandar', 'Gujarat'),
('GJ-26', 'Vyara', 'Gujarat'),
('GJ-27', 'Vastral', 'Gujarat'),
('GJ-28', 'Surat rural', 'Gujarat'),
('GJ-29', 'Vadodara rural', 'Gujarat'),
('GJ-3', 'Rajkot', 'Gujarat'),
('GJ-30', 'Ahwa', 'Gujarat'),
('GJ-31', 'Modasa', 'Gujarat'),
('GJ-32', 'Botad', 'Gujarat'),
('GJ-33', 'Botad', 'Gujarat'),
('GJ-34', 'Dwarka', 'Gujarat'),
('GJ-35', 'Lunawada', 'Gujarat'),
('GJ-36', 'Morbi', 'Gujarat'),
('GJ-37', 'Chhota Udaipur', 'Gujarat'),
('GJ-38', 'Kodinar', 'Gujarat'),
('GJ-4', 'Bhavnagar', 'Gujarat'),
('GJ-5', 'Surat city', 'Gujarat'),
('GJ-6', 'Vadodara city', 'Gujarat'),
('GJ-7', 'Nadiad', 'Gujarat'),
('GJ-8', 'Palanpur', 'Gujarat'),
('GJ-9', 'Himmatnagar', 'Gujarat'),
('HP-01', 'Shimla', 'Himachal Pradesh'),
('HP-02', 'Shimla', 'Himachal Pradesh'),
('HP-03', 'Shimla', 'Himachal Pradesh'),
('HP-04', 'Dharamsala', 'Himachal Pradesh'),
('HP-05', 'Mandi', 'Himachal Pradesh'),
('HP-06', 'Rampur', 'Himachal Pradesh'),
('HP-07', 'Shimla', 'Himachal Pradesh'),
('HP-08', 'Chaupal', 'Himachal Pradesh'),
('HP-09', 'Theog', 'Himachal Pradesh'),
('HP-10', 'Rohru', 'Himachal Pradesh'),
('HP-11', 'Arki', 'Himachal Pradesh'),
('HP-12', 'Nalagarh', 'Himachal Pradesh'),
('HP-13', 'Kandaghat', 'Himachal Pradesh'),
('HP-14', 'Solan', 'Himachal Pradesh'),
('HP-15', 'Parwanoo', 'Himachal Pradesh'),
('HP-16', 'Rajgarh', 'Himachal Pradesh'),
('HP-17', 'Paonta Sahib', 'Himachal Pradesh'),
('HP-18', 'Nahan', 'Himachal Pradesh'),
('HP-19', 'Amb', 'Himachal Pradesh'),
('HP-20', 'Una', 'Himachal Pradesh'),
('HP-21', 'Barsar, Hamirpur', 'Himachal Pradesh'),
('HP-22', 'Hamirpur', 'Himachal Pradesh'),
('HP-23', 'Ghumarwin', 'Himachal Pradesh'),
('HP-24', 'Bilaspur', 'Himachal Pradesh'),
('HP-25', 'Reckong Peo', 'Himachal Pradesh'),
('HP-26', 'Nichar (Bhaba Nagar)', 'Himachal Pradesh'),
('HP-27', 'Poo', 'Himachal Pradesh'),
('HP-28', 'Sarkaghat', 'Himachal Pradesh'),
('HP-29', 'Jogindernagar', 'Himachal Pradesh'),
('HP-30', 'Karsog', 'Himachal Pradesh'),
('HP-31', 'Sundernagar', 'Himachal Pradesh'),
('HP-32', 'Gohar, Mandi', 'Himachal Pradesh'),
('HP-33', 'Mandi', 'Himachal Pradesh'),
('HP-34', 'Kullu', 'Himachal Pradesh'),
('HP-35', 'Anni, Kullu', 'Himachal Pradesh'),
('HP-36', 'Dehra', 'Himachal Pradesh'),
('HP-37', 'Palampur', 'Himachal Pradesh'),
('HP-38', 'Nurpur', 'Himachal Pradesh'),
('HP-39', 'Dharamshala', 'Himachal Pradesh'),
('HP-40', 'Kangra', 'Himachal Pradesh'),
('HP-41', 'Kaza', 'Himachal Pradesh'),
('HP-42', 'Keylong', 'Himachal Pradesh'),
('HP-43', 'Udaipur', 'Himachal Pradesh'),
('HP-44', 'Churah', 'Himachal Pradesh'),
('HP-45', 'Pangi', 'Himachal Pradesh'),
('HP-46', 'Bharmour', 'Himachal Pradesh'),
('HP-47', 'Dalhousie', 'Himachal Pradesh'),
('MH-01', 'Mumbai', 'Maharashtra'),
('PB-11', 'Patiala', 'Punjab');

-- --------------------------------------------------------

--
-- Table structure for table `dummy`
--

CREATE TABLE `dummy` (
  `comp_id_dummy` varchar(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Triggers `dummy`
--
DELIMITER $$
CREATE TRIGGER `dummy_after_insert` AFTER INSERT ON `dummy` FOR EACH ROW begin
insert into road_test (comp_id)
values(new.comp_id_dummy);

end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `employee`
--

CREATE TABLE `employee` (
  `emp_id` varchar(12) NOT NULL,
  `ename` varchar(30) NOT NULL,
  `address` varchar(30) NOT NULL,
  `expertise` varchar(20) DEFAULT NULL,
  `tel_no_r` bigint(10) DEFAULT NULL,
  `mobile_no` bigint(10) DEFAULT NULL,
  `salary` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `employee`
--

INSERT INTO `employee` (`emp_id`, `ename`, `address`, `expertise`, `tel_no_r`, `mobile_no`, `salary`) VALUES
('E1', 'Mohan', 'Delhi', 'asdf', 9874563241, NULL, 216);

--
-- Triggers `employee`
--
DELIMITER $$
CREATE TRIGGER `atleast_one_num1_insert` BEFORE INSERT ON `employee` FOR EACH ROW begin
if((new.TEL_NO_R is null) and (new.mobile_no is null)) then
SIGNAL SQLSTATE '20001'
set MESSAGE_TEXT='Please provide atleast one of the contact numbers';
end if;
if(new.salary<0) THEN
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT='Salary should be greater than zero';
end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `atleast_one_num1_update` BEFORE UPDATE ON `employee` FOR EACH ROW begin
if((new.TEL_NO_R is null) and (new.mobile_no is null)) then
SIGNAL SQLSTATE '20001'
set MESSAGE_TEXT='Please provide atleast one of the contact numbers';
end if;
if(new.salary<0) THEN
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT='Salary should be greater than zero';
end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `insurance_claim`
--

CREATE TABLE `insurance_claim` (
  `claim_no` int(11) NOT NULL,
  `car_no` varchar(11) NOT NULL,
  `claim_date` datetime DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `comp_id` varchar(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `insurance_claim`
--

INSERT INTO `insurance_claim` (`claim_no`, `car_no`, `claim_date`, `amount`, `comp_id`) VALUES
(1, 'AR-07 12345', NULL, NULL, NULL),
(2, 'AR-07 12345', NULL, NULL, NULL);

--
-- Triggers `insurance_claim`
--
DELIMITER $$
CREATE TRIGGER `claim_for_insert` BEFORE INSERT ON `insurance_claim` FOR EACH ROW begin
DECLARE p int(11);
declare s int;
declare c1 cursor for select * from insurance_claim where car_no=(new.car_no) and claim_date>(DATE_ADD(new.claim_date,INTERVAL -6 MONTH));

open c1;
SELECT FOUND_ROWS() into s;
if (s=4) then
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT = 'You have already taken 4 claims in six months';
else
select max(claim_no)+1 into p from insurance_claim where car_no=new.car_no;
set new.claim_no = p;
if(new.claim_no is null) then
set new.claim_no=1;
end if;
end if;
close c1;
if(new.amount<0) THEN
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT='Amount should be greater than zero';
end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `claim_for_update` BEFORE UPDATE ON `insurance_claim` FOR EACH ROW BEGIN
if(new.amount<0) THEN
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT='Amount should be greater than zero';
end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `part_supplier`
--

CREATE TABLE `part_supplier` (
  `supplier_id` varchar(12) NOT NULL,
  `part_id` varchar(11) NOT NULL,
  `price_per_part` int(11) NOT NULL,
  `Qty_supplied` int(11) NOT NULL,
  `total_amount_charged` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `part_supplier`
--

INSERT INTO `part_supplier` (`supplier_id`, `part_id`, `price_per_part`, `Qty_supplied`, `total_amount_charged`) VALUES
('S1', 'P1', 78, 9, 702),
('S1', 'P1', 140, 14, 1960);

--
-- Triggers `part_supplier`
--
DELIMITER $$
CREATE TRIGGER `left_quantity2_afterinsert` AFTER INSERT ON `part_supplier` FOR EACH ROW Begin
declare s int;
select MAX(PRICE_PER_PART) into s from part_supplier WHERE PART_ID=NEW.PART_ID;
update spare_parts set AMOUNT_SOLD_FOR=s+50 WHERE PART_ID=NEW.PART_ID; 
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `left_quantity2_afterupdate` AFTER UPDATE ON `part_supplier` FOR EACH ROW Begin
declare s int;
select MAX(PRICE_PER_PART) into s from part_supplier WHERE PART_ID=NEW.PART_ID;
update spare_parts set AMOUNT_SOLD_FOR=s+50 WHERE PART_ID=NEW.PART_ID; 
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `left_quantity2_beforeinsert` BEFORE INSERT ON `part_supplier` FOR EACH ROW begin
declare s int(11);
declare v int(11);
if(new.qty_supplied <=0) then
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT='Please specify valid quantity';
end if;
if(new.PRICE_PER_PART<=0) then
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT='Please specify valid price';
end if;
set new.total_amount_charged=new.qty_supplied*new.price_per_part;
update spare_parts set qty_left=qty_left+(new.qty_supplied) where part_id=(new.part_id);

end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `left_quantity2_beforeupdate` BEFORE UPDATE ON `part_supplier` FOR EACH ROW begin
declare s int(11);
declare v int(11);
if(new.qty_supplied <=0) then
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT='Please specify valid quantity';
end if;
if(new.PRICE_PER_PART<=0) then
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT='Please specify valid price';
end if;
set new.total_amount_charged=new.qty_supplied*new.price_per_part;
update spare_parts set qty_left=qty_left+(new.qty_supplied) where part_id=(new.part_id);
select MAX(PRICE_PER_PART) into s from part_supplier WHERE part_id = new.part_id;
set v=s+50;
update spare_parts set AMOUNT_SOLD_FOR=v WHERE part_id=new.part_id;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `predefinedjobs`
--

CREATE TABLE `predefinedjobs` (
  `job_id` varchar(12) NOT NULL,
  `job_desc` varchar(30) DEFAULT NULL,
  `job_amount` int(11) DEFAULT NULL,
  `days_required` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `predefinedjobs`
--

INSERT INTO `predefinedjobs` (`job_id`, `job_desc`, `job_amount`, `days_required`) VALUES
('J1', 'fg', 63, 1),
('J2', 'jhmj', 807, 2);

--
-- Triggers `predefinedjobs`
--
DELIMITER $$
CREATE TRIGGER `days_atlest` BEFORE INSERT ON `predefinedjobs` FOR EACH ROW BEGIN
if(new.days_required <1) THEN
signal SQLSTATE '45000'
set MESSAGE_TEXT='Days required cannot be less than 1';
end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `road_test`
--

CREATE TABLE `road_test` (
  `test_id` int(11) NOT NULL,
  `car_no` varchar(11) DEFAULT NULL,
  `emp_id` varchar(11) DEFAULT NULL,
  `comp_id` varchar(11) NOT NULL,
  `km_out` int(11) DEFAULT NULL,
  `date_of_road_test` datetime DEFAULT NULL,
  `remarks` varchar(7) DEFAULT NULL,
  `road_test_scheduled` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `road_test`
--

INSERT INTO `road_test` (`test_id`, `car_no`, `emp_id`, `comp_id`, `km_out`, `date_of_road_test`, `remarks`, `road_test_scheduled`) VALUES
(1, 'CG-011234', 'E1', 'C3', 5, '2017-08-23 19:58:05', 'fit', '2017-08-24 19:57:38'),
(2, 'AR-07 12345', 'E1', 'C1', 15, '2017-08-23 19:44:21', 'unfit', '2017-08-24 19:07:08'),
(3, 'AR-07 12345', 'E1', 'C1', 0, '2017-08-23 19:58:31', 'unfit', '2017-08-24 19:44:21'),
(3, 'AR-17 8789', 'E1', 'C2', 15, '2017-08-23 20:00:10', 'unfit', '2017-08-24 19:08:06'),
(4, 'AR-07 12345', 'E1', 'C1', 4, '2017-08-23 19:59:29', 'fit', '2017-08-24 19:58:31'),
(4, 'AR-17 8789', 'E1', 'C2', NULL, NULL, 'Pending', '2017-08-24 20:00:10');

--
-- Triggers `road_test`
--
DELIMITER $$
CREATE TRIGGER `remarks_insert_before` BEFORE INSERT ON `road_test` FOR EACH ROW Begin
declare s varchar(12);
declare b int;
declare c datetime;
declare a varchar(11);
declare d varchar(12);
select car_no,supervised_by_empolyee into a,d from works_on_vehicle where comp_id =new.comp_id;
set new.car_no=a;
set new.emp_id=d;
select max(test_id)+1 into b from road_test where comp_id=new.comp_id;
set new.test_id = b;
if(new.test_id is null) then
set new.test_id=1;
end if;
set new.remarks='Pending';
select supervised_by_empolyee into s from works_on_vehicle where car_no=new.car_no and comp_id=new.comp_id;
set new.emp_id = s;
SELECT received_date into c from works_on_vehicle where comp_id=new.comp_id;
if(new.date_of_road_test<c) THEN
signal SQLSTATE '45000'
set MESSAGE_TEXT='Invalid date';
end if;
if(new.km_out<0) THEN
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT='Km should be greater than zero';
end if;
select remarks,date_of_road_test into s,c from road_test where comp_id=new.comp_id order by test_id DESC limit 1 ;
if(lower(s)='pending' or lower(s)='fit')
then
signal SQLSTATE '45000'
set MESSAGE_TEXT='Can''t insert';
end if;
if(lower(s)='unfit') THEN
set new.road_test_scheduled=Date_Add(c,INTERVAL 1 day);
end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `remarks_update_after` AFTER UPDATE ON `road_test` FOR EACH ROW BEGIN
if(lower(new.remarks)='fit') THEN
UPDATE works_on_vehicle set COMPLETION_date=CURRENT_TIMESTAMP() where comp_id=new.comp_id;
UPDATE works_on_vehicle set status='complete' where comp_id=new.comp_id;
end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `remarks_update_before` BEFORE UPDATE ON `road_test` FOR EACH ROW Begin
declare s varchar(12);
declare c datetime;
if((lower(new.remarks) not in ('unfit','fit')) or (new.remarks is null)) then
signal SQLSTATE '45000'
set MESSAGE_TEXT = 'Remarks shoud be fit or unfit';
end if;
select supervised_by_empolyee into s from works_on_vehicle where car_no=new.car_no and comp_id=new.comp_id;
set new.emp_id = s;
SELECT received_date into c from works_on_vehicle where comp_id=new.comp_id;
if(new.date_of_road_test<c) THEN
signal SQLSTATE '45000'
set MESSAGE_TEXT='Invalid date';
end if;
if(new.km_out<0) THEN
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT='Km should be greater than zero';
end if;
if(lower(new.remarks)='fit' or lower(new.remarks)='unfit') THEN
set new.date_of_road_test=CURRENT_TIMESTAMP();
end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `spare_parts`
--

CREATE TABLE `spare_parts` (
  `part_id` varchar(11) NOT NULL,
  `description` varchar(20) DEFAULT NULL,
  `qty_left` int(11) NOT NULL,
  `amount_sold_for` int(11) NOT NULL,
  `typ` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `spare_parts`
--

INSERT INTO `spare_parts` (`part_id`, `description`, `qty_left`, `amount_sold_for`, `typ`) VALUES
('P1', 'Spanner', 15, 190, 'paid');

--
-- Triggers `spare_parts`
--
DELIMITER $$
CREATE TRIGGER `QTY_LEFT_insert` BEFORE INSERT ON `spare_parts` FOR EACH ROW BEGIN

set NEW.QTY_LEFT:=0;
set new.amount_sold_for =0;

if(lower(new.typ) not in('warranty/paid','paid') or (new.typ is null) )then
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT = 'The type should be either ''Paid'' or ''Warranty/Paid''';
end if;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `left_quantity1_update` BEFORE UPDATE ON `spare_parts` FOR EACH ROW begin
declare s int;
if(new.qty_left<0) then
signal SQLSTATE '45000'
set MESSAGE_TEXT = 'Part is out of stock';
end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `specific_complaints`
--

CREATE TABLE `specific_complaints` (
  `complaint_id` varchar(20) NOT NULL,
  `task_no` int(11) NOT NULL,
  `task_description` varchar(30) DEFAULT NULL,
  `status` varchar(30) DEFAULT NULL,
  `days_required` int(2) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Triggers `specific_complaints`
--
DELIMITER $$
CREATE TRIGGER `add_days_after_insert` AFTER INSERT ON `specific_complaints` FOR EACH ROW BEGIN
Declare s datetime;
Declare r datetime;
SELECT estimated_completion_date,received_date into s,r from works_on_vehicle where comp_id=new.complaint_id;
if(s is null) THEN
update works_on_vehicle set estimated_completion_date=Date_ADD(r,interval new.days_required+1 day) where comp_id=new.complaint_id;
ELSE
update works_on_vehicle set estimated_completion_date=Date_ADD(s,interval new.days_required day) where comp_id=new.complaint_id; 
end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `spec_comp_after_update` AFTER UPDATE ON `specific_complaints` FOR EACH ROW BEGIN
declare a int;
declare b int;
declare c varchar(8);
DEClare d int;
declare e int;
select count(*) into a from specific_complaints where complaint_id=(new.complaint_id) and lower(status)='complete';
select count(*) into b from specific_complaints where complaint_id=(new.complaint_id);
select count(*) into d from comp_predefined where comp_id=(new.complaint_id) and lower(status)='complete';
select count(*) into e from comp_predefined where comp_id=(new.complaint_id);
select status into c from car_annual_service where comp_id=(new.complaint_id);
if (a=b and d=e and (c=lower('complete') or c is null) ) then
insert into road_test(comp_id,km_out,road_test_scheduled) values(new.complaint_id,5,DATE_ADD(CURRENT_TIMESTAMP(),INTERVAL 1 day));
end if;                                                              
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `status_before_update` BEFORE UPDATE ON `specific_complaints` FOR EACH ROW begin
if(lower(new.status)!='complete') then
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT = 'Plase update only when the task is completed';
end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `status_check_before_insert` BEFORE INSERT ON `specific_complaints` FOR EACH ROW begin
declare b int;
set new.status='Pending';
select max(task_no)+1 into b from specific_complaints where complaint_id=new.complaint_id;
set new.task_no = b;
if(new.task_no is null) then
set new.task_no=1;
end if;
if(new.days_required <1) THEN
signal SQLSTATE '45000'
set MESSAGE_TEXT='Days required cannot be less than 1';
end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `supplier`
--

CREATE TABLE `supplier` (
  `supplier_no` varchar(12) NOT NULL,
  `supplier_name` varchar(30) DEFAULT NULL,
  `supplier_location` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `supplier`
--

INSERT INTO `supplier` (`supplier_no`, `supplier_name`, `supplier_location`) VALUES
('S1', 'ytu', 'delhi');

-- --------------------------------------------------------

--
-- Table structure for table `vehicle`
--

CREATE TABLE `vehicle` (
  `customer_id` varchar(11) DEFAULT NULL,
  `car_no` varchar(11) NOT NULL,
  `car_model` varchar(11) DEFAULT NULL,
  `chassis_no` varchar(11) DEFAULT NULL,
  `eng_type` varchar(11) DEFAULT NULL,
  `year_purchased` int(4) DEFAULT NULL,
  `mileage` float(3,3) DEFAULT NULL,
  `vehicle_under_warranty` varchar(3) DEFAULT NULL,
  `Jurisdiction` varchar(30) DEFAULT NULL,
  `state` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `vehicle`
--

INSERT INTO `vehicle` (`customer_id`, `car_no`, `car_model`, `chassis_no`, `eng_type`, `year_purchased`, `mileage`, `vehicle_under_warranty`, `Jurisdiction`, `state`) VALUES
('C2', 'AR-0112345', NULL, NULL, NULL, NULL, NULL, NULL, 'Itanagar', 'Arunchal Paradesh'),
('C2', 'MH-01AV8866', NULL, NULL, NULL, NULL, NULL, NULL, 'Mumbai', 'Maharashtra'),
('C1', 'PB-11AX1234', NULL, NULL, NULL, NULL, NULL, NULL, 'Patiala', 'Punjab');

--
-- Triggers `vehicle`
--
DELIMITER $$
CREATE TRIGGER `jurdis_insert` BEFORE INSERT ON `vehicle` FOR EACH ROW begin
DECLARE r varchar(30);
Declare s varchar(30);

if((lower(new.vehicle_under_warranty) not in ('yes','no')))then
SIGNAL SQLSTATE '20001'
set MESSAGE_TEXT = 'Please enter whether the vehicle is under warranty (Yes/No)';
end if;
SELECT Jurisdiction,state into r,s from district where discode=substr(new.car_no,1,5);
set new.jurisdiction = r;
set new.state =s;
if((new.state is null) OR (new.jurisdiction is null)) then
SIGNAL SQLSTATE '20008'
set MESSAGE_TEXT = 'The number entered is invalid, please try manual insertion';
end if;
if((new.state is not null) and (new.jurisdiction is not null) and (new.customer_id is not null)) then
insert into works_on_vehicle(customer_id, car_no)
values(new.customer_id,new.car_no);
end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `jurdis_update` BEFORE UPDATE ON `vehicle` FOR EACH ROW begin
DECLARE r varchar(30);
Declare s varchar(30);

if((lower(new.vehicle_under_warranty) not in ('yes','no')))then
SIGNAL SQLSTATE '20001'
set MESSAGE_TEXT = 'Please enter whether the vehicle is under warranty (Yes/No)';
end if;
SELECT Jurisdiction,state into r,s from district where discode=substr(new.car_no,1,5);
set new.jurisdiction = r;
set new.state =s;
if((new.state is null) OR (new.jurisdiction is null)) then
SIGNAL SQLSTATE '20008'
set MESSAGE_TEXT = 'The number entered is invalid, please try manual insertion';
end if;
if((new.state is not null) and (new.jurisdiction is not null) and (new.customer_id is not null)) then
insert into works_on_vehicle(customer_id, car_no)
values(new.customer_id,new.car_no);
end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `works_on_vehicle`
--

CREATE TABLE `works_on_vehicle` (
  `comp_id` varchar(15) NOT NULL,
  `customer_id` varchar(11) NOT NULL,
  `car_no` varchar(11) NOT NULL,
  `supervised_by_empolyee` varchar(12) DEFAULT NULL,
  `Received_date` datetime DEFAULT NULL,
  `Out_date` datetime DEFAULT NULL,
  `completion_date` datetime DEFAULT NULL,
  `status` varchar(30) DEFAULT NULL,
  `estimated_completion_date` datetime DEFAULT NULL,
  `received_by_customer` varchar(3) DEFAULT NULL,
  `eligible_for_insurance` varchar(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `works_on_vehicle`
--

INSERT INTO `works_on_vehicle` (`comp_id`, `customer_id`, `car_no`, `supervised_by_empolyee`, `Received_date`, `Out_date`, `completion_date`, `status`, `estimated_completion_date`, `received_by_customer`, `eligible_for_insurance`) VALUES
('CP2', 'C1', 'PB-11AX1234', NULL, '2018-08-23 14:42:36', NULL, NULL, 'Pending', NULL, 'No', 'yes'),
('CP3', 'C2', 'AR-0112345', NULL, '2018-08-23 14:47:21', NULL, NULL, 'Pending', NULL, 'No', 'yes'),
('CP4', 'C2', 'MH-01AV8866', NULL, '2018-08-23 14:50:24', NULL, NULL, 'Pending', NULL, 'No', 'yes');

--
-- Triggers `works_on_vehicle`
--
DELIMITER $$
CREATE TRIGGER `employee_insert` BEFORE INSERT ON `works_on_vehicle` FOR EACH ROW begin
declare r datetime;
declare s int;
DECLARE t datetime;
declare a varchar(15);
declare b varchar(3);
declare c1 cursor for select * from insurance_claim where car_no=(new.car_no) and claim_date>(DATE_ADD(CURRENT_TIMESTAMP(),INTERVAL -6 MONTH));
declare c cursor for select * from works_on_vehicle where supervised_by_empolyee = new.supervised_by_empolyee  and lower(status)='pending';
open c;
SELECT FOUND_ROWS() into s ;
if (s=4) then
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT = 'The employee is too busy';
end if;
close c;
set new.received_by_customer="No";
select Out_date,Received_date into t,r from works_on_vehicle where car_no=new.car_no order by Received_date DESC limit 1 ;
if((t is null) and(r is not null)) THEN
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT = 'Car is already in garage';
end if;
set new.status = 'Pending';
set new.received_date = CURRENT_TIMESTAMP();
if(t>new.received_date) then 
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT = 'Invalid Entry';
end if;
if(new.out_date < new.completion_date) THEN
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT = 'Enter a valid out date';
end if;
if(new.out_date< new.received_date) THEN
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT = 'Out date is not valid';
end if;
select max(comp_id) into a from works_on_vehicle order by comp_id desc limit 1;
if(a is null) then
 set new.comp_id='CP1';
ELSE
 set new.comp_id=concat('CP',(cast(trim(leading 'CP' from a) as int)+1));
 end if;
set new.eligible_for_insurance='yes';
open c1;
SELECT FOUND_ROWS() into s;
if (s=4) then
set new.eligible_for_insurance='no';
end if;
close c1;
select vehicle_under_warranty into b from vehicle where car_no=new.car_no;
if(lower(b)='no') then
set new.eligible_for_insurance='no';
end if;
end
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `employee_update` BEFORE UPDATE ON `works_on_vehicle` FOR EACH ROW begin
declare a datetime;
declare b varchar(3);
declare s int;
declare c1 cursor for select * from insurance_claim where car_no=(new.car_no) and claim_date>(DATE_ADD(CURRENT_TIMESTAMP(),INTERVAL -6 MONTH));
declare c cursor for select * from works_on_vehicle where supervised_by_empolyee = new.supervised_by_empolyee  and lower(status)='pending';
open c;
SELECT FOUND_ROWS() into s ;
if (s=4) then
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT = 'The employee is too busy';
end if;
close c;
if(new.out_date < new.completion_date) THEN
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT = 'Enter a valid out date';
end if;
if(lower(new.received_by_customer) not in('yes','no')) then 
signal SQLSTATE '45000'
set MESSAGE_TEXT="Only can by yes or no";
end if;
if(new.out_date< new.received_date) THEN
SIGNAL SQLSTATE '45000'
set MESSAGE_TEXT = 'Out date is not valid';
end if;
SELECT CURRENT_service_date into a from car_annual_service where comp_id=new.comp_id and car_no=new.car_no;
if(a>new.completion_date) THEN
signal SQLSTATE '45000'
set MESSAGE_TEXT = 'INVALID DATE';
end if;
if(lower(new.received_by_customer)='yes' and lower(new.status)='pending') then
signal SQLSTATE '45000'
set MESSAGE_TEXT = 'Please let the repairs complete';
end if;
if(lower(new.received_by_customer)='yes' and lower(new.status)='complete') then
set new.out_Date=CURRENT_TIMESTAMP();
set new.eligible_for_insurance='yes';

open c1;
SELECT FOUND_ROWS() into s;
if (s=4) then
set new.eligible_for_insurance='no';
end if;
close c1;
select vehicle_under_warranty into b from vehicle where car_no=new.car_no;
if(lower(b)='no') then
set new.eligible_for_insurance='no';
end if; 
end if;
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bill`
--
ALTER TABLE `bill`
  ADD PRIMARY KEY (`bill_no`),
  ADD KEY `complaint_id` (`complaint_id`);

--
-- Indexes for table `car_annual_service`
--
ALTER TABLE `car_annual_service`
  ADD PRIMARY KEY (`comp_id`) USING BTREE;

--
-- Indexes for table `comp_part`
--
ALTER TABLE `comp_part`
  ADD PRIMARY KEY (`complaint_id`,`part_id`),
  ADD KEY `XZ` (`part_id`);

--
-- Indexes for table `comp_predefined`
--
ALTER TABLE `comp_predefined`
  ADD PRIMARY KEY (`comp_id`,`job_id`) USING BTREE,
  ADD KEY `XX` (`job_id`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`customer_id`);

--
-- Indexes for table `district`
--
ALTER TABLE `district`
  ADD PRIMARY KEY (`Discode`);

--
-- Indexes for table `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`emp_id`);

--
-- Indexes for table `insurance_claim`
--
ALTER TABLE `insurance_claim`
  ADD PRIMARY KEY (`claim_no`,`car_no`),
  ADD KEY `X` (`car_no`),
  ADD KEY `comp_id` (`comp_id`);

--
-- Indexes for table `part_supplier`
--
ALTER TABLE `part_supplier`
  ADD KEY `YY` (`part_id`),
  ADD KEY `Z` (`supplier_id`);

--
-- Indexes for table `predefinedjobs`
--
ALTER TABLE `predefinedjobs`
  ADD PRIMARY KEY (`job_id`);

--
-- Indexes for table `road_test`
--
ALTER TABLE `road_test`
  ADD PRIMARY KEY (`test_id`,`comp_id`) USING BTREE,
  ADD KEY `ZZX` (`comp_id`);

--
-- Indexes for table `spare_parts`
--
ALTER TABLE `spare_parts`
  ADD PRIMARY KEY (`part_id`);

--
-- Indexes for table `specific_complaints`
--
ALTER TABLE `specific_complaints`
  ADD PRIMARY KEY (`complaint_id`,`task_no`);

--
-- Indexes for table `supplier`
--
ALTER TABLE `supplier`
  ADD PRIMARY KEY (`supplier_no`);

--
-- Indexes for table `vehicle`
--
ALTER TABLE `vehicle`
  ADD PRIMARY KEY (`car_no`),
  ADD UNIQUE KEY `chassis_no` (`chassis_no`),
  ADD KEY `XYZ` (`customer_id`);

--
-- Indexes for table `works_on_vehicle`
--
ALTER TABLE `works_on_vehicle`
  ADD PRIMARY KEY (`comp_id`),
  ADD KEY `ZY` (`car_no`),
  ADD KEY `ZCY` (`supervised_by_empolyee`),
  ADD KEY `fk_customer_id` (`customer_id`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `comp_part`
--
ALTER TABLE `comp_part`
  ADD CONSTRAINT `XZ` FOREIGN KEY (`part_id`) REFERENCES `spare_parts` (`part_id`);

--
-- Constraints for table `comp_predefined`
--
ALTER TABLE `comp_predefined`
  ADD CONSTRAINT `XX` FOREIGN KEY (`job_id`) REFERENCES `predefinedjobs` (`job_id`);

--
-- Constraints for table `part_supplier`
--
ALTER TABLE `part_supplier`
  ADD CONSTRAINT `YY` FOREIGN KEY (`part_id`) REFERENCES `spare_parts` (`part_id`),
  ADD CONSTRAINT `Z` FOREIGN KEY (`supplier_id`) REFERENCES `supplier` (`supplier_no`);

--
-- Constraints for table `vehicle`
--
ALTER TABLE `vehicle`
  ADD CONSTRAINT `fkcusid` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);

--
-- Constraints for table `works_on_vehicle`
--
ALTER TABLE `works_on_vehicle`
  ADD CONSTRAINT `fk_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
  ADD CONSTRAINT `fk_supervised_by` FOREIGN KEY (`supervised_by_empolyee`) REFERENCES `employee` (`emp_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
