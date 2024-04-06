# ZFS Setup

This setup utilizes the ZFS file system along with various configurations to manage system and user data effectively.

## Configuration Options

### ZFS Options

- **Encrypted**: This option enables requesting credentials for ZFS encryption.
- **Symbolic Links**:
  - **System Cache Links**: Clears symbolic links for system cache directories.
  - **System Data Links**: Clears symbolic links for system data directories.
  - **Home Cache Links**: Clears symbolic links for home cache directories.
  - **Home Data Links**: Clears symbolic links for home data directories.
- **Ensure System Exists**: Ensures the existence of specified system directories. Example: `/data/etc/ssh`.
- **Ensure Home Exists**: Ensures the existence of specified home directories. Example: `~/.ssh`.
- **Root Dataset**: Specifies the root dataset for ZFS. Example: `rpool/local/root`.

## Configuration Settings

### Environment

- **Data Prefix**: Prefix for the data directory. Default: `/data`.
- **Cache Prefix**: Prefix for the cache directory. Default: `/cache`.
- **Persistence**: Configures persistence settings for the cache directory.
  - **Hide Mounts**: Hides mounts for persistence.
  - **Directories**: Specifies directories for persistence.
  - **User Directories**: Specifies user directories for persistence.

### Boot

- **Supported Filesystems**: Lists supported filesystems. Here, only ZFS is supported.
- **ZFS**:
  - **Dev Nodes**: Specifies device nodes for ZFS.
  - **Request Encryption Credentials**: Requests encryption credentials for ZFS.
- **Initrd Post Device Commands**: Executes commands after device initialization.

### Services

- **ZFS**: Configures services related to ZFS.
  - **Auto Scrub**: Enables automatic scrubbing.
  - **Trim**: Enables TRIM support.

## System Packages

- **ZFS Diff**: A script that performs a ZFS diff operation and filters the output to show only the added files or directories relevant to `/home/roelc/`.

## Activation Scripts

- **Ensure System Paths Exist**: A script to ensure the existence of specified system paths.
- **Ensure Home Paths Exist**: A script to ensure the existence of specified home paths and set ownership.

