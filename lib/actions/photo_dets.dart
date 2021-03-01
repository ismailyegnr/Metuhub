import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoDetails extends StatefulWidget {
  final photoURL;

  const PhotoDetails({Key key, this.photoURL}) : super(key: key);

  @override
  _PhotoDetailsState createState() => _PhotoDetailsState();
}

class _PhotoDetailsState extends State<PhotoDetails> {
  PhotoViewScaleStateController _photoController =
      PhotoViewScaleStateController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        PhotoView(
            scaleStateController: _photoController,
            loadingBuilder: (context, event) => Center(
                  child: CircularProgressIndicator(),
                ),
            scaleStateChangedCallback: (value) {
              setState(() {});
            },
            heroAttributes: PhotoViewHeroAttributes(
              tag: "${widget.photoURL}",
            ),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.contained * 3,
            gestureDetectorBehavior: HitTestBehavior.opaque,
            imageProvider: widget.photoURL == "assets/odtu.png"
                ? AssetImage(widget.photoURL)
                : CachedNetworkImageProvider(widget.photoURL)),
        _photoController.scaleState == PhotoViewScaleState.initial
            ? SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    iconSize: 22,
                    color: Colors.white,
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              )
            : SizedBox()
      ],
    ));
  }
}
