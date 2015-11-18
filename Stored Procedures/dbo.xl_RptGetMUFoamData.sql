SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[xl_RptGetMUFoamData]	
	@ShipmentDate	nvarchar(20)	,
	@ProdLine		nvarchar(20)	
AS

/*
	SELECT @ShipmentDate	='04-11-2015',
			@ProdLine		='PCL01'	 
*/

DECLARE	@tblMUData Table	(	RowId			int	IDENTITY	,
								PartNo			nvarchar(100)	,
								Descr			nvarchar(255)	,
								FoamType		int				,
								CompThickness	float			,
								IsStatic		bit				,
								StorageLocation	int				)
DECLARE	@tblOrder AS Table	(	RowId				int	IDENTITY	,
								OrderNo				nvarchar(100)	)


DECLARE @startRow	int				,
		@EndRow		int				,
		@SelOrder	nvarchar(20)	,
		@count		int		
INSERT INTO @tblOrder (orderNo)
			SELECT  Po.Pom_order_id
			FROM [SitMesDB].[dbo].POM_ORDER AS  Po 
				INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
				INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
				INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
				INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
				INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt2 ON Pe.pom_entry_pk = ocf_rt2.pom_entry_pk 
				INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val2 ON ocf_rt2.pom_custom_field_rt_pk = ocf_val2.pom_custom_field_rt_pk
			WHERE Pos.id IN ('PreProduction','Production','Scheduled','To Be Scheduled','Rework','Download')
				AND ocf_rt.pom_custom_fld_name='ShipmentDate'
				AND ocf_val.pom_cf_value= @ShipmentDate
				AND ocf_rt2.pom_custom_fld_name='ActualLine'
				AND ocf_val2.pom_cf_value= @ProdLine
INSERT INTO @tblMUData (PartNo,Descr)
	SELECT DISTINCT ml.def_id,md.Descript	
	FROM @tblOrder o
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER] AS Po ON Po.Pom_order_id=o.orderNo
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON Po.pom_order_pk = e.pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id
	WHERE ms.name='CONSUMED' 
	AND e.pom_entry_id like '%.MU%'
UPDATE @tblMUData
	SET IsStatic=Convert(bit,[PValue])
	FROM [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD
	INNER JOIN @tblMUData MUD ON MUD.PartNo=  MMD.DefID
	WHERE PropertyID='IsStatic' 
UPDATE @tblMUData
	SET StorageLocation=CONVERT(int,[PValue])
	FROM [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD
	INNER JOIN @tblMUData MUD ON MUD.PartNo=  MMD.DefID
	WHERE PropertyID=@ProdLine + '_FTPrimaryLocationAlias'
SELECT	PartNo					as 'Part No'			,
		Descr					as 'Description'		,
		CASE(IsStatic)
			WHEN 1 THEN 'Yes'
			WHEN 0 THEN 'No'	
		END						as 'Is Static'			,
		StorageLocation			as 'Storage Location'
FROM @tblMUData
ORDER BY IsStatic DESC
GO
