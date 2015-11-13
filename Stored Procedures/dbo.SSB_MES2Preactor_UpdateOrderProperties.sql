SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_MES2Preactor_UpdateOrderProperties]	
AS
	DECLARE @tblPOProperty as Table(	RowId			int IDENTITY	,
									OrderID			nvarchar(50)	,
									PropertyID		nvarchar(255)	,
									PropValue		nvarchar(50)	)

	INSERT INTO @tblPOProperty (OrderID,PropertyID,PropValue)
		SELECT  o.OrderID,CONVERT(nvarchar(255),DM.[APSProperty]),CONVERT(nvarchar(50),ocf_val.pom_cf_value)
			FROM  [SSB].[dbo].Temp_MES2Preactor AS o 
				INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
				INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
				INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
				INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
				INNER JOIN [SSB].[dbo].[MESPreactorDataMap] DM on DM.[MESProperty]= ocf_rt.pom_custom_fld_name
			WHERE DM.[DataFlow]='MES2Preactor'
				AND DM.[catagory]='Order'

	UPDATE [SSB].[dbo].Temp_MES2Preactor							/* TruckID  */
		SET	TruckID = Prop.PropValue		
		FROM @tblPOProperty AS Prop
			INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.OrderID
		WHERE PropertyID='TruckID'
	UPDATE [SSB].[dbo].Temp_MES2Preactor							/* StopID  */
			SET	StopID = Prop.PropValue		
			FROM @tblPOProperty AS Prop
				INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='StopID'
	UPDATE [SSB].[dbo].Temp_MES2Preactor							/* CustomerName  */
			SET	CustomerName = Prop.PropValue		
			FROM @tblPOProperty AS Prop
				INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='CustomerName'
	UPDATE [SSB].[dbo].Temp_MES2Preactor							/* CustomerOrderNo  */
			SET	CustomerOrderNo = Prop.PropValue		
			FROM @tblPOProperty AS Prop
				INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='CustomerOrderNo'
	UPDATE [SSB].[dbo].Temp_MES2Preactor							/* CustomerOrderLineNo  */
			SET	CustomerOrderLineNo = Prop.PropValue		
			FROM @tblPOProperty AS Prop
				INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='CustomerOrderLineNo'
	UPDATE [SSB].[dbo].Temp_MES2Preactor							/* DueDate  */
			SET	DueDate = Convert(date,Prop.PropValue,103) 
			FROM @tblPOProperty AS Prop
				INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='DueDate'
	UPDATE [SSB].[dbo].Temp_MES2Preactor							/* DueTime  */
			SET	DueTime = Convert(time(7),Prop.PropValue)	
			FROM @tblPOProperty AS Prop
				INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='DueTime'
	UPDATE [SSB].[dbo].Temp_MES2Preactor							/* ActualLine  */
			SET	ActualLine = Prop.PropValue
			FROM @tblPOProperty AS Prop
				INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='ActualLine'
	UPDATE [SSB].[dbo].Temp_MES2Preactor							/* WaveGroup */
			SET	WaveGroup = Prop.PropValue	
			FROM @tblPOProperty AS Prop
				INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='WaveGroup'
	UPDATE [SSB].[dbo].Temp_MES2Preactor							/* UnitType  */
			SET	UnitType = Prop.PropValue
			FROM @tblPOProperty AS Prop
				INNER JOIN [SSB].[dbo].Temp_MES2Preactor AS Po on  Po.OrderID	=Prop.OrderID
			 WHERE PropertyID='UnitType'
GO
