import pika
import base64
from google.cloud import storage
from datetime import datetime
import json

def callback(ch, method, properties, body):
    print("Recebendo mensagem...")
    # Decodifica a mensagem recebida
    gallery_data = json.loads(body)

    storage_client = storage.Client()
    bucket = storage_client.get_bucket('your-gcs-bucket-name')

    for image_data in gallery_data['imagens']:
        image_content = base64.b64decode(image_data['imagem'])
        image_name = f"{image_data['titulo']}_{datetime.now().strftime('%d%m%Y%H%M%S')}.jpg"
        blob = bucket.blob(image_name)
        blob.upload_from_string(image_content, content_type='image/jpeg')
        print(f"Imagem {image_name} salva no bucket.")

def main():
    connection = pika.BlockingConnection(pika.ConnectionParameters(host='rabbitmq-service'))
    channel = connection.channel()
    channel.queue_declare(queue='galleryQueue')
    channel.basic_consume(queue='galleryQueue', on_message_callback=callback, auto_ack=True)

    print('Esperando por mensagens. Pressione CTRL+C para sair.')
    channel.start_consuming()

if __name__ == "__main__":
    main()
