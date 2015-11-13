CREATE TABLE [dbo].[SSB_MES2Preactor]
(
[SID] [int] NOT NULL IDENTITY(1, 1),
[OrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProcessType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PlantNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EntryID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerOrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerOrderLineNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TruckID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StopID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DueDate] [date] NOT NULL,
[DueTime] [time] NULL,
[Quantity] [int] NOT NULL,
[FGPart] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FGPartDesc] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SAPart] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SAPartDesc] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BedSize] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Height] [real] NULL,
[Width] [real] NOT NULL,
[Length] [real] NOT NULL,
[ItemClass] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoreType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PanelType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltNeedleSetting] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltPatternCAM] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltTick] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltBacking] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltLayer1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltLayer2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltLayer3] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltLayer4] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltLayer5] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltLayer6] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderTick] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderRP] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderRF] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderBK] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderWidth] [float] NULL,
[BorderNeedleBar] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Borderpattern] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderNletHeight] [float] NULL,
[BorderBDRGroup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThreadLineColor] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderLabel] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BDType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BDSAPart] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderStitch] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderRibbon] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderRibbonCord] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NLET] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ByPass] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderHandle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderHandleStyle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderHandleWidth] [float] NULL,
[BorderHandleGroup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GussettSAPart] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GussettTick] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GussettRP] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GussettRF] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GussettBK] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GussettNeedleBar] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gussettpattern] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GussettHeight] [float] NULL,
[GussettGroup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderWire] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoilSeries] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoilType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoilWireGage] [float] NULL,
[CoilsperRow] [int] NULL,
[CoilQuantity] [float] NULL,
[TotalNoofRows] [int] NULL,
[FEC] [bit] NULL,
[NumberOfMULayers] [int] NULL,
[ActualLine] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WaveGroup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnitType] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderCord] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MattressSides] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SSB_MES2Preactor] ADD CONSTRAINT [PK_SSB_MES2Preactor_2] PRIMARY KEY CLUSTERED  ([SID]) ON [PRIMARY]
GO
