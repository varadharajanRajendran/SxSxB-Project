SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[InsertBorderData]
	-- Add the parameters for the stored procedure here
	@OrderNo nvarchar(20),@ProcessType nvarchar(20),@PlantNo nvarchar(20),@CustomerName nvarchar(255),@CustomerOrderNo nvarchar(20),@CustomerOrderLineNo nvarchar(20),
@TruckID nvarchar(20),@StopID nvarchar(10),@DueDate date,@Quantity int,@FGPart nvarchar(30),@FGPartDesc nvarchar(255),@BedSize nvarchar(10),@Width real,@Length real,
@ProductType nvarchar(30),@BorderType nvarchar(30),@CoreType nvarchar(30),@NumberOfMULayers int,@PanelType nvarchar(50),
@SAPart nvarchar(30),@SAPartDesc nvarchar(255),@EntryID nvarchar(255),@BorderTick nvarchar(14),@BorderWidth float,@BorderLabel nvarchar(14),@BorderStitch nvarchar(14),@BorderRibbon nvarchar(14),@BorderHandle nvarchar(14),@BorderHandleStyle nvarchar(14)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
insert into SSB_MES2Preactor
(OrderNo,ProcessType,PlantNo,CustomerName,CustomerOrderNo,CustomerOrderLineNo,
TruckID,StopID,DueDate,Quantity,FGPart,FGPartDesc,BedSize,Width,Length,
ProductType,BorderType,CoreType,NumberOfMULayers,PanelType,
SAPart,SAPartDesc,EntryID,BorderTick,BorderWidth,BorderLabel,BorderStitch,BorderRibbon,BorderHandle,BorderHandleStyle
) values( @OrderNo,@ProcessType,@PlantNo,@CustomerName,@CustomerOrderNo,@CustomerOrderLineNo,
@TruckID,@StopID,@DueDate,@Quantity,@FGPart,@FGPartDesc,@BedSize,@Width,@Length,
@ProductType,@BorderType,@CoreType,@NumberOfMULayers,@PanelType,
@SAPart,@SAPartDesc,@EntryID,@BorderTick,@BorderWidth,@BorderLabel,@BorderStitch,@BorderRibbon,@BorderHandle,@BorderHandleStyle)
END
GO
