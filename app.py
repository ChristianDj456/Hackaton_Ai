from flask import Flask, request, jsonify
import google.generativeai as genai
import pandas as pd
from dotenv import load_dotenv
import os

load_dotenv()

app = Flask(__name__)

# Configurar la API de Gemini
API_KEY = os.getenv('APIKEY')
genai.configure(api_key=API_KEY)  # Reemplaza "YOUR_API_KEY" con tu clave API real AIzaSyC1v4t0KfsBDz15hpmWL0CJ12nQhaBIMSs

# Seleccionar el modelo
model = genai.GenerativeModel('gemini-1.5-flash')

# Cargar y preprocesar los datos
file_path = 'sport_clothing_sales_data_with_discounts.csv'
data = pd.read_csv(file_path)
data = data[['name', 'sub_title', 'description', 'price', 'availability', 'available_sizes', 'color', 'quantity', 'classify', 'discount', 'final_price']]
data['text'] = data.apply(lambda row: f"Producto: {row['name']}\nSubtítulo: {row['sub_title']}\nDescripción: {row['description']}\nPrecio: {row['price']}\nDisponibilidad: {row['availability']}\nTallas: {row['available_sizes']}\n Colores: {row['color']}\n Cantidad: {row['quantity']}\n Tipo: {row['classify']}\n Ofertas: {row['discount']}\n Precio Final: {row['final_price']}", axis=1)
corpus = "\n\n".join(data['text'].tolist())

# Definir palabras clave relevantes



palabras_clave = ["traje","disponible","tiene","tienes","T-Shirt",
"Jersey",
"Pants",
"Tights",
"Overalls",
"Jacket",
"Dress",
"Shorts",
"Hoodie",
"Cap","la","camisillas","calcetas","gorra","calcetin","camisetas","vermudas","calzado","medias","zapatos","pantalón","camisa","el", "producto", "Nike", "precio", "disponibilidad", "descripción", "tallas", "colores", "opiniones", "calificación", "sizes", "color","Dri-FIT",
"Cotton",
"Polyester",
"Spandex",
"Waterproof",
"Breathable","Soccer",
"Basketball",
"Running",
"Training",
"Yoga",
"Golf","Long-Sleeve",
"Short-Sleeve",
"High-Waist",
"Low-Waist",
"Fitted",
"Loose",
"Lightweight",
"Reflective", "Sportswear",
"Pro",
"Air",
"Max",
"Academy",
"Club","Limited Edition",
"Special Edition"
"PSG (Paris Saint-Germain)",
"NBA",
"MLB"]


prompt_inicial = '''
Tu nombre es "Niki Chatbot", trabajas para la empresa de ropa deportiva "Sporty". Tu cargo consiste en brindar apoyo a nuestros empleados sobre el almacenamiento y inventario actual, por ende tus respuestas hacia ellos deben de ser formales y precisas
solamente puedes responder preguntas que esten relacionadas a la informacion dentro de tu base de datos. a continuacion se brindan ejemplos de posibles preguntas.
*Pregunta:* ¿Cuál es el precio del producto "Nike Dri-FIT Team (MLB Minnesota Twins)"?

*Respuesta:* El precio del producto "Nike Dri-FIT Team (MLB Minnesota Twins)" es de $40.00 USD.

*Pregunta:* ¿Está disponible el producto "Club América"?

*Respuesta:* No, el producto "Club América" está disponible en stock.

*Pregunta:* ¿Qué colores están disponibles para el producto "Nike Sportswear Swoosh"?

*Respuesta:* El producto "Nike Sportswear Swoosh" está disponible en los colores Black & White.

*Pregunta:* ¿Qué tallas están disponibles para el producto "Nike Dri-FIT One Luxe"?

*Respuesta:* Las tallas disponibles para el producto "Nike Dri-FIT One Luxe" no están especificadas.

*Pregunta:* ¿Qué características tiene el producto "Paris Saint-Germain Repel Academy AWF"?

*Respuesta:* El producto "Paris Saint-Germain Repel Academy AWF" ofrece cobertura repelente al agua con detalles de PSG.

*Pregunta:* ¿Qué colores estan disponibles para los productos?

*Respuesta:* Varían segun el producto. Algunos de los colores listados incluyen Navy, Black/Black, Black/White, Black/Rush Pink, Dark Grey/Black/Siren Red. 

*Pregunta:* ¿Hay productos para niños?

*Respuesta:* Si, algunos productos específicos para niños incluyen "Nike Dri-Fit One Luxe Big Kids' (Girls') Printed tights (Extended Size) y "Paris Saint Germain Repel Academy AWF Big Kids' Soccer Jacket.
'''

response = model.generate_content(prompt_inicial)

def generar_respuesta(corpus, pregunta):
    prompt = f"{corpus}\n\nPregunta: {pregunta}\nRespuesta: "
    response = model.generate_content(prompt)
    return response.text

@app.route("/preguntar", methods=["POST"])
def preguntar():
    data = request.json
    pregunta = data["pregunta"]
    
    # Verificar si la pregunta contiene alguna palabra clave
    if any(palabra in pregunta.lower() for palabra in palabras_clave):
        respuesta = generar_respuesta(corpus, pregunta)
        return jsonify({"respuesta": respuesta})
    else:
        return jsonify({"respuesta": "Lo siento, solo puedo responder preguntas relacionadas con los productos de la empresa."})

if __name__ == "__main__":
    app.run(port=5000)
