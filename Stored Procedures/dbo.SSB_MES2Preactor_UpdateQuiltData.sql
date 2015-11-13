SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_MES2Preactor_UpdateQuiltData]	
AS

DECLARE @tblEntryProperty as Table(	RowId			int IDENTITY	,
									EntryID			nvarchar(50)	,
									PropertyID		nvarchar(255)	,
									PropValue		nvarchar(50)	)

INSERT INTO @tblEntryProperty(EntryID,PropertyID,PropValue)		/* Panel Quilter */
		SELECT  o.EntryID,CONVERT(nvarchar(255),DM.[APSProperty]),CONVERT(nvarchar(50),ocf_val.pom_cf_value)
			FROM  [SSB].[dbo].Temp_MES2Preactor AS o 
				INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
				INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
				INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
				INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
				INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]= ocf_rt.pom_custom_fld_name
			WHERE DM.[DataFlow]='MES2Preactor'
				AND DM.[catagory]='Quilt'
			AND  o.ProcessType='Quilter'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* QuiltNeedleSetting  */
	SET	QuiltNeedleSetting = Prop.PropValue		
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=Prop.EntryID
	WHERE PropertyID='QuiltNeedleSetting'		
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* QuiltPatternCAM  */
	SET	QuiltPatternCAM = Prop.PropValue		
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=Prop.EntryID
	WHERE PropertyID='QuiltPatternCAM'	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* QuiltTick  */
	SET	QuiltTick   = Prop.PropValue		
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=Prop.EntryID
	WHERE PropertyID='QuiltTick'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* QuiltBacking */
	SET	QuiltBacking = Prop.PropValue		
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=Prop.EntryID
	WHERE PropertyID='QuiltBacking'
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* QuiltLayer1  */
	SET	QuiltLayer1	 = Prop.PropValue		
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=Prop.EntryID
	WHERE PropertyID='QuiltLayer1'	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* QuiltLayer2  */
	SET	QuiltLayer2	 = Prop.PropValue		
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=Prop.EntryID
	WHERE PropertyID='QuiltLayer2'		
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* QuiltLayer3  */
	SET	QuiltLayer3	 = Prop.PropValue		
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=Prop.EntryID
	WHERE PropertyID='QuiltLayer3'	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* QuiltLayer4  */
	SET	QuiltLayer4	 = Prop.PropValue		
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=Prop.EntryID
	WHERE PropertyID='QuiltLayer4'		
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* QuiltLayer5  */
	SET	QuiltLayer5	 = Prop.PropValue		
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=Prop.EntryID
	WHERE PropertyID='QuiltLayer5'	
UPDATE [SSB].[dbo].Temp_MES2Preactor							/* QuiltLayer6  */
	SET	QuiltLayer6	 = Prop.PropValue		
	FROM @tblEntryProperty  AS Prop
		INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.EntryID	=Prop.EntryID
	WHERE PropertyID='QuiltLayer6'		

GO
