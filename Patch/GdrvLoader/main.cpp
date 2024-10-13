#include "global.h"

int wmain(int argc, wchar_t** argv)
{
	NTSTATUS Status;
	if (argc == 3)
	{
		// Load driver
		Status = WindLoadDriver(argv[1], argv[2], FALSE);
		if (!NT_SUCCESS(Status))
			Printf(L"Driver load error: %08x\n", Status);
	}
	else if (argc == 2)
	{
		// Unload driver
		Status = WindUnloadDriver(argv[1], 0);
		if (NT_SUCCESS(Status))
			Printf(L"Driver unloaded successfully.\n");
		else
			Printf(L"Error unloading driver: %08X\n", Status);
	}
	else
	{
		// Dump CI/boot options/kernel debugger info
		Status = PrintSystemInformation();
	}
	return Status;
}
