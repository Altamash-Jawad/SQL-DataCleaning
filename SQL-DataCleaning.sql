/* 
Data Cleaning Using SQL Queries
*/

SELECT *
FROM NashvilleHousing;
-------------------------------------------------------------------------------------------
-- Standardized Date Format

SELECT SaleDate, CONVERT(Date, SaleDate) AS DateOfSale
-- Fetching from SaleDate without the useless timestamps
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);
-- Updating SaleDate column with a new name SaleDateConverted (timestamp removed)

-------------------------------------------------------------------------------------------
-- Populate Property Address Data

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousing a
    JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
        AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NOT NULL;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
    JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
        AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;
-- Here we had duplicate ParcelID with UniqueID and we updated the null PropertyAddress using ParcelID as reference

-------------------------------------------------------------------------------------------
-- Breaking the Address into Individual Columns (Address, City, State). Current Address example: 1808 FOX CHASE DR, GOODLETTSVILLE

SELECT PropertyAddress
FROM NashvilleHousing;

SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
-- Dividing the Address column using SUBSTRING and defining location using CHARINDEX
FROM NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);
-- Adding separate address field and data with UPDATE

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);
-- Adding separate city field and data from UPDATE statement below 

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))




SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), -- This is another easier method for separating columns using PARSENAME
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);
-- Adding separate address field and data with UPDATE (This is using PARSENAME), Address 

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);
-- Adding separate city field and data with UPDATE

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);
-- Adding separate state field and data with UPDATE

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field using the CASE statement and then UPDATE table 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
    CASE
    WHEN SoldAsVacant = 'Y' THEN 'YES'
    WHEN SoldAsVacant = 'N' THEN 'NO'
    ELSE SoldAsVacant
    END
FROM NashvilleHousing;


UPDATE NashvilleHousing
SET 
SoldAsVacant =  CASE
    WHEN SoldAsVacant = 'Y' THEN 'YES'
    WHEN SoldAsVacant = 'N' THEN 'NO'
    ELSE SoldAsVacant
    END

-------------------------------------------------------------------------------------------

-- Remove Duplicates- In standard practice we make a temp table and then remove the duplicates and not from the actual database (SP) - WIP
-- First we are going to find duplicate values

WITH
    RowNumCTE
    AS
    
    (
        SELECT *,
            ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
            ORDER BY 
            UniqueID
            ) row_num
        FROM NashvilleHousing
    )
-- There is an error in this query
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-------------------------------------------------------------------------------------------
-- In this section we are going to delete unused columns

SELECT *
FROM
    NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate