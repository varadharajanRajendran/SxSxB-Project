SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_BOM_EOL_GetPLCDS]
		@OrderID nvarchar(255)	
AS
 
----------------------------------Declare Variables and Tables----------------------

DECLARE	@intStartRow		int				,
        @intEndRow			int				,
        @intelProc			int				,
		@PartNo				nvarchar(100)	,
		@OIrderID			nvarchar(255)	,	
		@BoxCount			int				,
		@PalletPack			nvarchar(2)		,
		@selEntry			nvarchar(255)	,
		@TruckID			nvarchar(100)	,
		@StopLoc			nvarchar(100)	,
		@CartNo				nvarchar(5)		   /* Reservered for Future */
			
DECLARE	@tblPLCDS AS Table	(	RowId		int	IDENTITY	,
								RTDSTag		nvarchar(100)	,
								Value		nvarchar(50)	,
								[DataType]	nvarchar(255)	)

/* Product Properties*/
INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
	VALUES ('JOBID',@OrderID , 'String')

SELECT @BoxCount=COUNT(Pe.pom_entry_id)
FROM[SitMesDB].[dbo].[POM_ENTRY] Pe
	INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po on Po.pom_order_pk=Pe.pom_order_pk
WHERE Pe.pom_entry_id like '%BOXPKG%'
	AND Po.[pom_order_id]=@OrderID
			
IF @BoxCount>0
	BEGIN					  
		SELECT @selEntry=Pe.pom_entry_id
		FROM[SitMesDB].[dbo].[POM_ENTRY] Pe
			INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po on Po.pom_order_pk=Pe.pom_order_pk
		WHERE Pe.pom_entry_id like  '%BOXPKG%'
			AND Po.[pom_order_id]=@OrderID
		
		SELECT @PartNo=ML.def_id
		FROM [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] MS
			INNER JOIN  [SitMesDB].[dbo].[POM_ENTRY] PE on PE.[pom_entry_pk]=Ms.pom_entry_pk
			INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] ML on ML.pom_material_specification_pk=MS.pom_material_specification_pk
		WHERE MS.name='PRODUCED'
			AND PE.pom_entry_id like '%' + @selEntry + '%'		
				
		SELECT @PalletPack=CONVERT(nvarchar(255),[SitMesDB].[dbo].[MMfBinToPropVal](MMPV.[PropValue], 0) )
		FROM [SitMesDB].[dbo].[MMBoms] MMB
			INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMD on MMB.DefPK=MMD.DefPK
			INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MMBA	on MMBa.BomPK=MMB.BomPK
			INNER JOIN [SitMesDB].[dbo].[MMBomAltPrpVals] MMPV on MMPV.BomAltPK=MMBA.BomAltPK
			INNER JOIN [SitMesDB].[dbo].[MMProperties] MMP on MMP.PropertyPK=MMPV.PropertyPK
			WHERE MMD.DefID=@PartNo
			AND MMP.PropertyID='PALETIZEDFINISHEDMATTPACKS'

		IF @PalletPack='Y'
			BEGIN
				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					VALUES('UNITSIZE','0' ,'Numeric')
				
				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					VALUES('BOXPKG','0' ,'Numeric')
			END
		ELSE
			BEGIN
				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					VALUES('UNITSIZE',RIGHT(@PartNo,2) ,'Numeric')	
				
				INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					VALUES('BOXPKG',1 ,'Numeric')
		END
	END
 ELSE
	BEGIN
			INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
				VALUES('UNITSIZE','0' ,'Numeric')
			
			INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
					VALUES('BOXPKG','0' ,'Numeric')
	END

	SELECT  @TruckID=CONVERT(varchar(max),ocf_val.pom_cf_value)
	FROM    [SitMesDB].[dbo].POM_CAMPAIGN AS c INNER JOIN
			[SitMesDB].[dbo].POM_ORDER AS o ON c.pom_campaign_pk = o.pom_campaign_pk INNER JOIN
			[SitMesDB].[dbo].POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk INNER JOIN
			[SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON e.pom_entry_pk = ocf_rt.pom_entry_pk INNER JOIN
			[SitMesDB].[dbo].POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
	WHERE   (e.order_extended_data = 'Y')
		AND o.pom_order_id=@OrderID
		AND ocf_rt.pom_custom_fld_name='TruckID'

	IF @TruckID='n/a' or @TruckID='NULL' or @TruckID='' or LOWER(@TruckID)='z'  or @TruckID IS NULL
	BEGIN
		SELECT @TruckID='0'
	END

	INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
		VALUES('TRUCKID',@TruckID ,'String')


	SELECT  @StopLoc=CONVERT(varchar(max),ocf_val.pom_cf_value)
	FROM    [SitMesDB].[dbo].POM_CAMPAIGN AS c INNER JOIN
			[SitMesDB].[dbo].POM_ORDER AS o ON c.pom_campaign_pk = o.pom_campaign_pk INNER JOIN
			[SitMesDB].[dbo].POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk INNER JOIN
			[SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON e.pom_entry_pk = ocf_rt.pom_entry_pk INNER JOIN
			[SitMesDB].[dbo].POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
	WHERE   (e.order_extended_data = 'Y')
		AND o.pom_order_id=@OrderID
		AND ocf_rt.pom_custom_fld_name='StopLocationID'

	IF @StopLoc='n/a' or @StopLoc='NULL' or @StopLoc='' or LOWER(@StopLoc)='z'  or @StopLoc IS NULL
	BEGIN
		SELECT @StopLoc='0'
	END

	INSERT INTO @tblPLCDS (RTDSTag,Value,[DataType])
		VALUES('STOPLOCATIONID',@StopLoc ,'Numeric')

SELECT RTDSTag,Value,[DataType] FROM @tblPLCDS
GO
