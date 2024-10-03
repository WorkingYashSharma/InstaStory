import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:story_app/models/user_model.dart';
import 'package:video_player/video_player.dart';

class StoryScreen extends StatefulWidget {
  final List<User> users;  // List of users
  final int initialUserIndex;  // Initial user index

  StoryScreen({required this.users, required this.initialUserIndex});

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int currentUserIndex;
  int currentStoryIndex = 0;
  late AnimationController _animationController;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    currentUserIndex = widget.initialUserIndex;
    _pageController = PageController(initialPage: currentUserIndex);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });
    _startStory();
  }

  void _startStory() {
    final currentStory = widget.users[currentUserIndex].stories[currentStoryIndex];

    _animationController.reset();
    _animationController.forward();

    if (currentStory.mediaType == 'video') {
      _videoController = VideoPlayerController.network(currentStory.mediaUrl)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
        });
    }
  }

  void _nextStory() {
    if (currentStoryIndex < widget.users[currentUserIndex].stories.length - 1) {
      setState(() {
        currentStoryIndex++;
        _startStory();
      });
    } else {
      if (currentUserIndex < widget.users.length - 1) {
        // Move to the next user
        setState(() {
          currentUserIndex++;
          currentStoryIndex = 0;  // Reset story index for the new user
          _pageController.animateToPage(currentUserIndex,
              duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
          _startStory();
        });
      } else {
        Navigator.pop(context); // If no more users, go back
      }
    }
  }

  void _previousStory() {
    if (currentStoryIndex > 0) {
      setState(() {
        currentStoryIndex--;
        _startStory();
      });
    } else {
      if (currentUserIndex > 0) {
        // Move to the previous user
        setState(() {
          currentUserIndex--;
          currentStoryIndex = 0;  // Reset story index for the previous user
          _pageController.animateToPage(currentUserIndex,
              duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
          _startStory();
        });
      } else {
        Navigator.pop(context); // If at the first story and first user, go back
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        physics: ClampingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            currentUserIndex = index;
            currentStoryIndex = 0;  // Reset story index when switching users
            _startStory();
          });
        },
        itemCount: widget.users.length,
        itemBuilder: (context, index) {
          final currentUser = widget.users[index];
          final currentStory = currentUser.stories[currentStoryIndex];

          return GestureDetector(
            onTap: _nextStory,
            onDoubleTap: _previousStory,
            onLongPress: () {
              _animationController.stop();
              _videoController?.pause();
            },
            onLongPressUp: () {
              _animationController.forward();
              _videoController?.play();
            },
            child: Stack(
              children: [
                // Media display (Image or Video)
                currentStory.mediaType == 'image'
                    ? Hero(
                  tag: 'profile-pic-${currentUser.userId}',
                  child: CachedNetworkImage(
                    imageUrl: currentStory.mediaUrl,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                )
                    : _videoController != null && _videoController!.value.isInitialized
                    ? Center(
                  child: FittedBox(
                    fit: BoxFit.contain, // Ensure the video fits properly
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                )
                    : Center(child: CircularProgressIndicator()),

                // Progress Indicator for each story
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: currentUser.stories.map((story) {
                      int storyIndex = currentUser.stories.indexOf(story);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            child: LinearProgressIndicator(
                              value: storyIndex == currentStoryIndex
                                  ? _animationController.value
                                  : storyIndex < currentStoryIndex
                                  ? 1.0
                                  : 0.0,
                              backgroundColor: Colors.white54,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Story text and description
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentStory.text,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        currentStory.textDescription,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),

                // Custom Back Button
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
