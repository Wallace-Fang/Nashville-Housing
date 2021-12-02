Select *
From [Nashville Housing].dbo.Housing



--Standardize Date Format
Select SaleDateConverted, CONVERT(Date, SaleDate)
From [Nashville Housing].dbo.Housing

Update Housing
Set SaleDate = Convert(Date,SaleDate)

ALTER TABLE Housing
Add SaleDateConverted Date;

Update Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)



--Populate Property Address Data
Select *
From [Nashville Housing].dbo.Housing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Nashville Housing].dbo.Housing a
JOIN [Nashville Housing].dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Nashville Housing].dbo.Housing a
JOIN [Nashville Housing].dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null



--Breaking out Address into Individual Columns(Address, City, State)
Select PropertyAddress
From [Nashville Housing].dbo.Housing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From [Nashville Housing].dbo.Housing

ALTER TABLE Housing
Add PropertySplitAddress Nvarchar(255)

Update Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Housing
Add PropertySplitCity Nvarchar(255);

Update Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



Select *
From [Nashville Housing].dbo.Housing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From [Nashville Housing].dbo.Housing

ALTER TABLE Housing
Add OwnerSplitAddress Nvarchar(255)

Update Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Housing
Add OwnerSplitCity Nvarchar(255);

Update Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Housing
Add OwnerSplitState Nvarchar(255)

Update Housing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From [Nashville Housing].dbo.Housing


--Convert'Y'and 'N'to 'Yes' and 'No'
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Nashville Housing].dbo.Housing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From [Nashville Housing].dbo.Housing

Update Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
	) row_num
From [Nashville Housing].dbo.Housing
)

Select*
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


--Delete Unused Columns
Select *
From [Nashville Housing].dbo.Housing

ALTER TABLE [Nashville Housing].dbo.Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Nashville Housing].dbo.Housing
DROP COLUMN SaleDate
