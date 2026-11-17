-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Server version: 10.11.16-MariaDB
-- PHP Version: 8.3.36

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `federal_audit`
--

-- --------------------------------------------------------

--
-- Table structure for table `access_logs`
--

CREATE TABLE `access_logs` (
  `LogID` int(11) NOT NULL,
  `EmployeeID` int(11) NOT NULL,
  `Last_Login_Date` date NOT NULL,
  `Data_Accessed` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `access_logs`
--

INSERT INTO `access_logs` (`LogID`, `EmployeeID`, `Last_Login_Date`, `Data_Accessed`) VALUES
(1, 1001, '2026-11-10', 'Threat_Intel_Report'),
(2, 1002, '2026-11-12', 'Network_Topology'),
(3, 1003, '2026-06-01', 'Payroll_Records'),
(4, 1004, '2026-11-05', 'Network_Topology'),
(5, 1005, '2026-08-01', 'Network_Topology'),
(6, 1006, '2026-11-14', 'Threat_Intel_Report'),
(7, 1002, '2026-11-15', 'Public_Newsletter');

-- --------------------------------------------------------

--
-- Table structure for table `clearance_levels`
--

CREATE TABLE `clearance_levels` (
  `Level_Name` varchar(50) NOT NULL,
  `Level_Rank` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `clearance_levels`
--

INSERT INTO `clearance_levels` (`Level_Name`, `Level_Rank`) VALUES
('Confidential', 2),
('Secret', 3),
('Top Secret', 4),
('Unclassified', 1);

-- --------------------------------------------------------

--
-- Table structure for table `data_assets`
--

CREATE TABLE `data_assets` (
  `Data_Accessed` varchar(50) NOT NULL,
  `Classification` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `data_assets`
--

INSERT INTO `data_assets` (`Data_Accessed`, `Classification`) VALUES
('Payroll_Records', 'Confidential'),
('Network_Topology', 'Secret'),
('Threat_Intel_Report', 'Top Secret'),
('Public_Newsletter', 'Unclassified');

-- --------------------------------------------------------

--
-- Table structure for table `employees`
--

CREATE TABLE `employees` (
  `EmployeeID` int(11) NOT NULL,
  `ClearanceLevel` varchar(50) NOT NULL,
  `Department` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employees`
--

INSERT INTO `employees` (`EmployeeID`, `ClearanceLevel`, `Department`) VALUES
(1001, 'Top Secret', 'Intelligence'),
(1002, 'Secret', 'IT Security'),
(1003, 'Confidential', 'HR'),
(1004, 'Unclassified', 'Finance'),
(1005, 'Secret', 'IT Security'),
(1006, 'Confidential', 'Operations'),
(1007, 'Unclassified', 'Facilities');

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_inactive_accounts`
-- (See below for the actual view)
--
CREATE TABLE `v_inactive_accounts` (
`EmployeeID` int(11)
,`Department` varchar(50)
,`LastLogin` date
,`DaysInactive` int(8)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_privilege_violations`
-- (See below for the actual view)
--
CREATE TABLE `v_privilege_violations` (
`LogID` int(11)
,`EmployeeID` int(11)
,`EmployeeClearance` varchar(50)
,`Data_Accessed` varchar(50)
,`DataClassification` varchar(50)
);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `access_logs`
--
ALTER TABLE `access_logs`
  ADD PRIMARY KEY (`LogID`),
  ADD KEY `EmployeeID` (`EmployeeID`),
  ADD KEY `Data_Accessed` (`Data_Accessed`);

--
-- Indexes for table `clearance_levels`
--
ALTER TABLE `clearance_levels`
  ADD PRIMARY KEY (`Level_Name`);

--
-- Indexes for table `data_assets`
--
ALTER TABLE `data_assets`
  ADD PRIMARY KEY (`Data_Accessed`),
  ADD KEY `Classification` (`Classification`);

--
-- Indexes for table `employees`
--
ALTER TABLE `employees`
  ADD PRIMARY KEY (`EmployeeID`),
  ADD KEY `ClearanceLevel` (`ClearanceLevel`);

-- --------------------------------------------------------

--
-- Structure for view `v_inactive_accounts`
--
DROP TABLE IF EXISTS `v_inactive_accounts`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_inactive_accounts`  AS SELECT `e`.`EmployeeID` AS `EmployeeID`, `e`.`Department` AS `Department`, max(`l`.`Last_Login_Date`) AS `LastLogin`, to_days(curdate()) - to_days(max(`l`.`Last_Login_Date`)) AS `DaysInactive` FROM (`employees` `e` left join `access_logs` `l` on(`e`.`EmployeeID` = `l`.`EmployeeID`)) GROUP BY `e`.`EmployeeID`, `e`.`Department` HAVING `LastLogin` is null OR `DaysInactive` > 90 ;

-- --------------------------------------------------------

--
-- Structure for view `v_privilege_violations`
--
DROP TABLE IF EXISTS `v_privilege_violations`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_privilege_violations`  AS SELECT `l`.`LogID` AS `LogID`, `e`.`EmployeeID` AS `EmployeeID`, `e`.`ClearanceLevel` AS `EmployeeClearance`, `d`.`Data_Accessed` AS `Data_Accessed`, `d`.`Classification` AS `DataClassification` FROM ((((`access_logs` `l` join `employees` `e` on(`l`.`EmployeeID` = `e`.`EmployeeID`)) join `data_assets` `d` on(`l`.`Data_Accessed` = `d`.`Data_Accessed`)) join `clearance_levels` `ec` on(`e`.`ClearanceLevel` = `ec`.`Level_Name`)) join `clearance_levels` `dc` on(`d`.`Classification` = `dc`.`Level_Name`)) WHERE `dc`.`Level_Rank` > `ec`.`Level_Rank` ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `access_logs`
--
ALTER TABLE `access_logs`
  ADD CONSTRAINT `access_logs_ibfk_1` FOREIGN KEY (`EmployeeID`) REFERENCES `employees` (`EmployeeID`),
  ADD CONSTRAINT `access_logs_ibfk_2` FOREIGN KEY (`Data_Accessed`) REFERENCES `data_assets` (`Data_Accessed`);

--
-- Constraints for table `data_assets`
--
ALTER TABLE `data_assets`
  ADD CONSTRAINT `data_assets_ibfk_1` FOREIGN KEY (`Classification`) REFERENCES `clearance_levels` (`Level_Name`);

--
-- Constraints for table `employees`
--
ALTER TABLE `employees`
  ADD CONSTRAINT `employees_ibfk_1` FOREIGN KEY (`ClearanceLevel`) REFERENCES `clearance_levels` (`Level_Name`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
