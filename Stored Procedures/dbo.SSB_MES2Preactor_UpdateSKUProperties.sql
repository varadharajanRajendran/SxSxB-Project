SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_MES2Preactor_UpdateSKUProperties]	
AS

DECLARE @tblSKU as Table	(	RowId			int IDENTITY	,
								SKU				nvarchar(50)	)
DECLARE @tblSKUProperty as Table(	RowId			int IDENTITY	,
									SKU				nvarchar(50)	,
									PropertyID		nvarchar(255)	,
									PropValue		nvarchar(50)	)

INSERT INTO @tblSKU(SKU)
	SELECT DISTINCT(FGPArt)
	FROM [SSB].[dbo].Temp_MES2Preactor
INSERT INTO @tblSKUProperty(SKU	,PropertyID,PropValue)
	SELECT	Po.SKU,
			DM.[APSProperty],
			CONVERT(nvarchar(50),BAPV.PValue)
	FROM  [SitMesDB].dbo.MMvBomAltPrpVals AS BAPV WITH (NOLOCK) 
		  INNER JOIN  [SitMesDB].dbo.MMBomAlts AS BA WITH (NOLOCK) ON BA.BomAltPK = BAPV.BomAltPK 
		  INNER JOIN  [SitMesDB].dbo.MMBoms AS B WITH (NOLOCK) ON B.BomPK = BA.BomPK 
		  INNER JOIN  [SitMesDB].dbo.MMDefinitions AS D WITH (NOLOCK) ON D.DefPK = B.DefPK 
		  INNER JOIN  [SitMesDB].dbo.MMProperties AS P WITH (NOLOCK) ON P.PropertyPK = BAPV.PropertyPK 
		  INNER JOIN  @tblSKU Po ON Po.SKU=D.[DefID]
		  INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]=P.PropertyID
	WHERE DM.[DataFlow]='MES2Preactor'
		 AND DM.[catagory]='SKU'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* SKU Description  */
	SET	FGPartDesc = [Descript]		
	FROM [SSB].[dbo].Temp_MES2Preactor AS Po
		INNER JOIN  [SitMesDB].[dbo].[MMDefinitions] MM on  MM.DefID= Po.FGPart
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* ProductType  */
	SET	ProductType = CASE(Prop.PropValue)
						WHEN 'INNER SPRING' THEN 'INNER SPRING'
						ELSE Prop.PropValue
					END
	FROM @tblSKUProperty AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.FGPart	=Prop.SKU
	 WHERE PropertyID='ProductType '	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BorderType  */
	SET	BorderType = CASE(Prop.PropValue)
						WHEN '1' THEN 'PT'
						WHEN '0' THEN 'TT'
						ELSE Prop.PropValue
					END	
	FROM @tblSKUProperty AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.FGPart	=Prop.SKU
	WHERE PropertyID='BorderType'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* BedSize */
	SET	BedSize = Prop.PropValue		
	FROM @tblSKUProperty AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.FGPart	=Prop.SKU
	WHERE PropertyID='BedSize'	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* Length */
	SET	[Length] = CONVERT(real,Prop.PropValue)		
	FROM @tblSKUProperty AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.FGPart	=Prop.SKU
	WHERE PropertyID='Length'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* Width */
	SET	[Width] = CONVERT(real,Prop.PropValue	)	
	FROM @tblSKUProperty AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.FGPart	=Prop.SKU
	WHERE PropertyID='Width'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* NumberOfMULayers */
	SET	NumberOfMULayers =  CONVERT(int,Prop.PropValue	)	
	FROM @tblSKUProperty AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.FGPart	=Prop.SKU
	WHERE PropertyID='NumberOfMULayers'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* CoreType  */
	SET	CoreType = CASE Prop.PropValue	
						WHEN '1' THEN 'Make'
						WHEN '0' THEN 'Buy'	
					END
	FROM @tblSKUProperty AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.FGPart	=Prop.SKU
	WHERE PropertyID='CoreType'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* PanelType   */
	SET	[PanelType] = CASE (Prop.PropValue)	
						WHEN '1'	THEN 'Quilt'
						WHEN '2'	THEN 'nonQuilt'	
						WHEN '0'	THEN 'nonQuilt'	
						ELSE Prop.PropValue	
					  END
	FROM @tblSKUProperty AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.FGPart	=Prop.SKU
	WHERE PropertyID='PanelType'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* PanelType2  */
	SET	[PanelType2] = CASE Prop.PropValue	
							WHEN '1'	THEN 'Quilt'
							WHEN '2'	THEN 'nonQuilt'	
							WHEN '0'	THEN 'nonQuilt'	
							ELSE Prop.PropValue	
		 			   END		
	FROM @tblSKUProperty AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.FGPart	=Prop.SKU
	WHERE PropertyID='PanelType2'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* FEC  */
	SET	FEC = CASE Prop.PropValue	
					WHEN 'FEC'	THEN '1'
					WHEN 'non-FEC'	THEN '0'
					WHEN 'nonFEC'	THEN '0'		
					ELSE Prop.PropValue	
			  END		
	FROM @tblSKUProperty AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.FGPart	=Prop.SKU
	WHERE PropertyID='FEC'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* MattressSides  */
	SET	MattressSides = Prop.PropValue	
	FROM @tblSKUProperty AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.FGPart	=Prop.SKU
	WHERE PropertyID='MattressSides'

	
	
GO
