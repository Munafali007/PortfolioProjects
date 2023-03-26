-- Cleaning Data in SQL Queries

Select *
From PortfolioProject..Nhousing

------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate) 
From PortfolioProject.dbo.Nhousing
 
Update Nhousing
SET SaleDate = CONVERT(Date, SaleDate)

-- If it doesn't Update Properly

ALTER TABLE Nhousing
Add SaleDateConverted Date;

Update Nhousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From PortfolioProject.dbo.Nhousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.Nhousing a
JOIN PortfolioProject.dbo.Nhousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Nhousing a
JOIN PortfolioProject.dbo.Nhousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress 
From PortfolioProject.dbo.Nhousing
--Where PropertyAddress is null
--Order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.Nhousing

ALTER TABLE Nhousing
Add PropertySplitAddress Nvarchar(255);

Update Nhousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Nhousing
Add PropertySplitCity Nvarchar(255);

Update Nhousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.Nhousing


Select OwnerAddress
From PortfolioProject.dbo.Nhousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)
From PortfolioProject.dbo.Nhousing

ALTER TABLE PortfolioProject.dbo.Nhousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.Nhousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)

ALTER TABLE PortfolioProject.dbo.Nhousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.Nhousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProject.dbo.Nhousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.Nhousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject.dbo.Nhousing

-----------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.Nhousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
,CASE When SoldAsVacant = 'Y' THEN 'Yes'
	  When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant 
	  END
From PortfolioProject.dbo.Nhousing

Update PortfolioProject.dbo.Nhousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	  When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant 
	  END

------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
		         PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					)  as row_num

From PortfolioProject.dbo.Nhousing
-- Order by ParcelID
)

Select*
From RowNumCTE
Where row_num > 1
Order By PropertyAddress


Select *
From PortfolioProject.dbo.Nhousing

---------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.Nhousing

ALTER TABLE PortfolioProject.dbo.Nhousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


























