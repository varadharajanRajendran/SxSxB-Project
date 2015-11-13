CREATE TABLE [dbo].[SSB_Terminals]
(
[pk] [int] NOT NULL IDENTITY(1, 1),
[Terminal_Name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IpAddress] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MACID] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeviceType] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comments] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SSB_Terminals] ADD CONSTRAINT [PK_SSB_Terminals] PRIMARY KEY CLUSTERED  ([pk]) ON [PRIMARY]
GO
