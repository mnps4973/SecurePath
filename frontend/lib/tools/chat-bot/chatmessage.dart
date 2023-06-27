import 'package:flutter/material.dart';
import 'package:frontend/tools/faq.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    Key? key,
    required this.text,
    required this.sender,
    this.isImage = false,
    this.backgroundColor = Colors.indigo,
  }) : super(key: key);

  final String text;
  final String sender;
  final bool isImage;
  final Color backgroundColor;



  @override
  Widget build(BuildContext context) {
    Color color = Colors.indigo;
    switch (sender) {
      case "Cop":
        color = Colors.indigo;
        break;
      case "Translate":
      case "Recommendation":
        color = const Color(0xFF7986CB);
        break;
    }
    void navigateToFaQPageWithQuery(BuildContext context, String query) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FAQPage(initialQuery: query)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(sender == 'Cop' ? 'assets/images/tourist.png' : 'assets/images/chatbot.png'),
            backgroundColor: Colors.white,
            radius: 18.0,
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: color,
                border: Border.all(
                  color: color,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sender != 'Recommendation' ? text.trim() : "Our Recommendation!",
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  if (sender == "Recommendation")
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.question_answer),
                          color: Colors.white,
                          onPressed: () {
                            navigateToFaQPageWithQuery(context, text);
                          },
                        ),
                        Text(
                          "Procure na nossa FAQ",
                          style: Theme.of(context).textTheme.caption?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        ],
                    )

                ],
              ),
            ),
          ),
        ],
      ),
    );


  }
}
