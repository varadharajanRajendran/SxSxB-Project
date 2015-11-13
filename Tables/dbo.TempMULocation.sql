CREATE TABLE [dbo].[TempMULocation]
(
[pk] [int] NOT NULL IDENTITY(1, 1),
[Location] [int] NOT NULL,
[PartNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PickID] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
