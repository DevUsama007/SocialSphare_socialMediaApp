import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loop_page_view/loop_page_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_sphere/homepage_screens/followedUserPost/short_video_screen/shortVideoPlayer.dart';

class ShortVideoFollowed extends StatefulWidget {
  const ShortVideoFollowed({super.key});

  @override
  State<ShortVideoFollowed> createState() => _ShortVideoFollowedState();
}

class _ShortVideoFollowedState extends State<ShortVideoFollowed> {
  //clear post functio is going
  show() {
    return FirebaseFirestore.instance.collection('short_videos').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: StreamBuilder<QuerySnapshot>(
        stream: show(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Shimmer.fromColors(
                baseColor: Color.fromARGB(255, 240, 239, 239),
                direction: ShimmerDirection.rtl,
                highlightColor: Color.fromARGB(255, 193, 191, 191),
                child: Container(
                  color:
                      const Color.fromARGB(255, 140, 140, 140).withOpacity(0.1),
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_fill,
                        size: 90,
                        color: Colors.black,
                      ),
                      Text("Fetching...")
                    ],
                  )),
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Text("error occured");
          }
          return LoopPageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: snapshot.data!.docs.length == 0
                ? 1
                : snapshot.data!.docs.length,
            itemBuilder: (_, index) {
              return snapshot.data!.docs.length == 0
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Shimmer.fromColors(
                        baseColor: Color.fromARGB(255, 240, 239, 239),
                        direction: ShimmerDirection.rtl,
                        highlightColor: Color.fromARGB(255, 193, 191, 191),
                        child: Container(
                          color: const Color.fromARGB(255, 140, 140, 140)
                              .withOpacity(0.1),
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_circle_fill,
                                size: 90,
                                color: Colors.black,
                              ),
                              Text("NO SHORT FOUND")
                            ],
                          )),
                        ),
                      ),
                    )
                  : FullScreenVideoPlayer(
                      videoUrl:
                          snapshot.data!.docs[index]['postUrl'].toString(),
                      userProfileImage: snapshot
                          .data!.docs[index]['userprofileImage']
                          .toString(),
                      userName:
                          snapshot.data!.docs[index]['username'].toString(),
                      name: snapshot.data!.docs[index]['name'].toString(),
                      postId: snapshot.data!.docs[index]['postID'].toString(),
                      uid: snapshot.data!.docs[index]['userID'].toString(),
                    );
            },
          );
        },
      ),
    );
  }
}
