CREATE TABLE [dbo].[SSB_FTLocations]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[PartNo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PackSize] [int] NULL,
[Unit] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCLIsStatic] [bit] NULL,
[PCLPrimary] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCLSec] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HYLIsStatic] [bit] NULL,
[HYLPrimary] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HYLSec] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMLIsStatic] [bit] NULL,
[CMLPrimary] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMLSec] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpLIsStatic] [bit] NULL,
[SpLPrimary] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpLSec] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SSB_FTLocations] ADD CONSTRAINT [PK_SSB_MULocSetting] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
