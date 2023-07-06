# Project Title

Simple Storage Management.

Overview Diagram:
![image](https://github.com/johren1910/gold-storage/assets/132887874/b87e7096-b686-47ad-ab7b-8357afa45b12)


## Description

Simple app that support download media like Pictures & Videos.

☑️ Simple Clean Architecture: ChatDetail

☑️ Simple Coordinator Pattern

☑️ Simple DatabaseService with Repository & Unit-of-Work Pattern

☑️ Simple Download Manager. Utilising PriorityQueue. Current support URLSessionDownloadRepository.

☑️ Simple State management with ZOStatePresentable.

☑️ Simple CacheService: Ram cache & Disk cache

☑️ Simple Dependency Injection

☑️ Simple Compression Helper

☑️ Simple Hash Helper

☑️ Simple File Helper 

☑️ Simple SQLite3 Utility 

☑️ Simple Skeletonable protocol for view

☑️ Thread-safe

TODO:
- Auto retry download
- Storage space management
- Decouple ZOStatePresentable for better handling.
- Error handling
- Support File
- Expand DownloadRepository
- Optimize Hash for large files
- Apply CA for ChatRoom
- Migrate to relatedPath instead of absolutePath
- Add Flick API for better demo
- Utilising FBLPromise for better handling & scalable.

## Getting Started

### Dependencies

- IGListKit

### Installing

1. Clone.
2. Pod install.
3. Using.

## Authors

Quannm10@vng.com.vn

## Version History
* 0.5
    * Repository & Unit-of-work pattern for database  
    * CA for ZODownloadManager
    * PriorityQueue for ZODownloadManager
* 0.4
    * Basic CA
    * Dependency Injection
    * ZOStatePresentable
    * SkeletonLoading

* 0.3
    * DownloadManager
    * CacheService
    * DatabaseService
    * Coordinator pattern
    * Hash helper
    * File helper
    * Compression Helper
* 0.2
    * Basic MVVM 
* 0.1
    * Initial Release

## License

This project is licensed under the MIT License - see the LICENSE.md file for details

## Acknowledgments

Thank Mr.Hung for extensive guiding & support me in making this project.
