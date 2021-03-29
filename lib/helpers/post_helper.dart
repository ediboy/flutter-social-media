import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_social_media/models/post_model.dart';
import 'package:flutter_social_media/services/post_service.dart';
import 'package:timeago/timeago.dart';

class PostHelper {
  final int _limit = 6;
  bool noMoreData;
  bool _isLoading = false;
  List<DocumentSnapshot> _data = [];
  Stream<List<PostModel>> stream;
  DocumentSnapshot _lastDocument;
  StreamController<List<DocumentSnapshot>> _controller;
  ScrollController scrollController;

  // load initial records
  void loadPosts() {
    _data = [];
    _controller = StreamController<List<DocumentSnapshot>>.broadcast();
    _isLoading = false;
    scrollController = ScrollController();

    stream = _controller.stream.map((List<DocumentSnapshot> postsData) {
      return postsData.map((snap) => PostModel.fromFirestore(snap)).toList();
    });
    noMoreData = false;
    refresh();
  }

  // refresh data
  Future<void> refresh() {
    return loadMore(clearCacheData: true);
  }

  // load more data from firebase
  Future<void> loadMore({bool clearCacheData = false}) {
    // clear all data if refreshed
    if (clearCacheData) {
      _data = [];
      noMoreData = false;
      _lastDocument = null;
    }

    // just return if still loading or doesn't have more data
    if (_isLoading || noMoreData) {
      return Future.value();
    }

    // set loading to true then fetch posts
    _isLoading = true;
    return PostService().getPosts(_limit, _lastDocument).then((postsData) {
      // set the last document for the next query
      if (postsData.docs.length != 0) {
        _lastDocument = postsData.docs[postsData.docs.length - 1];

        _data.addAll(postsData.docs);
      }

      // check if there is no more next data
      if (postsData.docs.length < _limit) {
        noMoreData = true;
      }

      _controller.add(_data);
      _isLoading = false;
    });
  }

  String converDate(DateTime createdAt) {
    final _now = DateTime.now();
    _now.difference(createdAt).inDays;

    if (_now.difference(createdAt).inDays > 0) {
      return format(
          _now.subtract(new Duration(days: _now.difference(createdAt).inDays)));
    }

    if (_now.difference(createdAt).inHours > 0) {
      return format(_now
          .subtract(new Duration(hours: _now.difference(createdAt).inHours)));
    }

    if (_now.difference(createdAt).inMinutes > 0) {
      return format(_now.subtract(
          new Duration(minutes: _now.difference(createdAt).inMinutes)));
    }

    return format(_now
        .subtract(new Duration(seconds: _now.difference(createdAt).inSeconds)));
  }
}
