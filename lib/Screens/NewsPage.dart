import 'dart:convert';
import 'package:flutter/src/material/colors.dart';
import 'package:alarm_clock_app/models/news.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:shimmer_animation/shimmer_animation.dart' hide Shimmer;
import 'HomeScreen.dart';
class Newspage extends StatefulWidget {
  const Newspage({super.key});

  @override
  State<Newspage> createState() => _NewspageState();
}

class _NewspageState extends State<Newspage> {
  Future FetchNews() async
  {
    final url= 'https://newsapi.org/v2/everything?q=tesla&from=2025-08-04&sortBy=publishedAt&apiKey=c9e0a3c371734c6daee195e854032d63';
    var response = await http.get(Uri.parse(url));
    if(response.statusCode == 200)
      {
        final result = jsonDecode(response.body);
        return News_Api.fromJson(result);
      }
    else
      {
        return News_Api();
      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        titleSpacing: 0,
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text("Latest News",style: TextStyle(color: Colors.yellow),),
        actions: [

          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> Homescreen())
            );
          },
              icon: Icon(Icons.arrow_back,color:Colors.yellow,)
          )
        ],
      ),
      body: FutureBuilder(future: FetchNews(),
          builder: (context, snapshot)
          {
            if (snapshot.connectionState == ConnectionState.waiting){
              return Shimmereffect();
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong", style: TextStyle(color: Colors.white)));
            }

            if (!snapshot.hasData || snapshot.data!.articles.isEmpty) {
              return const Center(child: Text("No news available", style: TextStyle(color: Colors.white)));
            }
           return ListView.builder( itemBuilder:((context , index){
            return ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          snapshot.data!.articles[index].urlToImage ?? '',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          snapshot.data!.articles[index].author ?? "Unknown Author",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    snapshot.data!.articles[index].title ?? "No Title",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              subtitle: Column(
                children: [
                  Text(
                    snapshot.data!.articles[index].description ?? "No description",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    snapshot.data!.articles[index].content ?? "No Detail",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
            }), itemCount:snapshot.data!.articles.length);
          }
      ),
    );
  }
}
class Shimmereffect extends StatelessWidget {
  @override
  Widget build(BuildContext context)
  {
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[600]!,
          child: Container(
            height: 800,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}