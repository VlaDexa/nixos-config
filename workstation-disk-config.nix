{backup, ...}:
{
	disko.devices = {
		disk = {
			backup = {
				type = "disk";
				device = backup;
				content = {
					type = "gpt";
					partitions = {
						main = {
							size = "100%";
							content = {
								type = "filesystem";
								format = "ext4";
								mountpoint = "/mnt/Backup";
							};
						};
					};
				};
			};
		};
	};
}
