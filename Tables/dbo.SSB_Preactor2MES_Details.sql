CREATE TABLE [dbo].[SSB_Preactor2MES_Details]
(
[SID] [int] NOT NULL IDENTITY(1, 1),
[BatchNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BatchDateTime] [datetime] NULL,
[OrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PlantNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcessName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActualLine] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Resource] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sequence] [int] NULL,
[EntryID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerOrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CusotmerOrderLineNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKUNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quantity] [int] NULL,
[DueDate] [datetime] NULL,
[SetupTime] [float] NULL,
[ProcessTime] [float] NULL,
[SetupStart] [datetime] NULL,
[StartTime] [datetime] NULL,
[EndTime] [datetime] NULL,
[TruckID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StopID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsInFirstSlice] [bit] NULL,
[AvailableLines] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OperationGroup1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OperationGroup2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OperationGroup3] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BatchGroup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WaveGroup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SSB_Preactor2MES_Details] ADD CONSTRAINT [PK_SSB_Preactor2MES] PRIMARY KEY CLUSTERED  ([SID]) ON [PRIMARY]
GO
