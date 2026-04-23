/*
 Navicat Premium Dump Script

 Source Server         : MongoDB
 Source Server Type    : MongoDB
 Source Server Version : 80206 (8.2.6)
 Source Host           : localhost:27017
 Source Schema         : db_trip

 Target Server Type    : MongoDB
 Target Server Version : 80206 (8.2.6)
 File Encoding         : 65001

 Date: 22/04/2026 17:06:03
*/


// ----------------------------
// Collection structure for compras
// ----------------------------
db.getCollection("compras").drop();
db.createCollection("compras");

// ----------------------------
// Documents of compras
// ----------------------------
db.getCollection("compras").insert([ {
    _id: ObjectId("69e92223ee3e2b6b23011640"),
    id_usuario: ObjectId("69e922e3ee3e2b6b23011646"),
    dlc: [
        {
            nombre: "Final alternativo",
            fecha: ISODate("2026-04-21T12:00:00.000Z")
        }
    ]
} ]);
db.getCollection("compras").insert([ {
    _id: ObjectId("69e92233ee3e2b6b23011642"),
    id_usuario: ObjectId("69e9231cee3e2b6b23011648"),
    dlc: [
        {
            nombre: "Nivel extra: Pesadilla",
            fecha: ISODate("2026-04-22T14:00:00.000Z")
        }
    ]
} ]);

// ----------------------------
// Collection structure for dlc
// ----------------------------
db.getCollection("dlc").drop();
db.createCollection("dlc");

// ----------------------------
// Documents of dlc
// ----------------------------
db.getCollection("dlc").insert([ {
    _id: ObjectId("69e92090ee3e2b6b23011628"),
    nombre: "Final alternativo",
    descripcion: "Nuevo final del juego",
    precio: 50
} ]);
db.getCollection("dlc").insert([ {
    _id: ObjectId("69e920a4ee3e2b6b2301162a"),
    nombre: "Nivel extra: Pesadilla",
    descripcion: "Nivel con mayor dificultad",
    precio: 30
} ]);

// ----------------------------
// Collection structure for estado_mental
// ----------------------------
db.getCollection("estado_mental").drop();
db.createCollection("estado_mental");

// ----------------------------
// Documents of estado_mental
// ----------------------------
db.getCollection("estado_mental").insert([ {
    _id: ObjectId("69e920eeee3e2b6b2301162c"),
    id_usuario: ObjectId("69e9227bee3e2b6b23011644"),
    estado: "normal",
    intensidad: 0.2,
    efectos: [ ],
    fecha: ISODate("2026-04-22T10:00:00.000Z")
} ]);
db.getCollection("estado_mental").insert([ {
    _id: ObjectId("69e920f9ee3e2b6b2301162e"),
    id_usuario: ObjectId("69e922e3ee3e2b6b23011646"),
    estado: "alterado",
    intensidad: 0.6,
    efectos: [
        "vision_borrosa",
        "ligera_distorsion"
    ],
    fecha: ISODate("2026-04-20T15:30:00.000Z")
} ]);
db.getCollection("estado_mental").insert([ {
    _id: ObjectId("69e92107ee3e2b6b23011630"),
    id_usuario: ObjectId("69e9231cee3e2b6b23011648"),
    estado: "critico",
    intensidad: 0.9,
    efectos: [
        "pantalla_glitch",
        "distorsion_fuerte",
        "controles_invertidos"
    ],
    fecha: ISODate("2026-04-18T08:45:00.000Z")
} ]);

// ----------------------------
// Collection structure for inventarios
// ----------------------------
db.getCollection("inventarios").drop();
db.createCollection("inventarios");

// ----------------------------
// Documents of inventarios
// ----------------------------
db.getCollection("inventarios").insert([ {
    _id: ObjectId("69e91fb1ee3e2b6b2301161a"),
    id_usuario: ObjectId("69e9227bee3e2b6b23011644"),
    objetos: [
        {
            nombre: "Llave",
            cantidad: 1
        },
        {
            nombre: "Pastilla",
            cantidad: 2
        }
    ]
} ]);
db.getCollection("inventarios").insert([ {
    _id: ObjectId("69e91fd3ee3e2b6b2301161c"),
    id_usuario: ObjectId("69e922e3ee3e2b6b23011646"),
    objetos: [
        {
            nombre: "Linterna",
            cantidad: 1
        }
    ]
} ]);
db.getCollection("inventarios").insert([ {
    _id: ObjectId("69e91fe2ee3e2b6b2301161e"),
    id_usuario: ObjectId("69e9231cee3e2b6b23011648"),
    objetos: [
        {
            nombre: "Pastilla",
            cantidad: 3
        },
        {
            nombre: "Nota",
            cantidad: 1
        }
    ]
} ]);

// ----------------------------
// Collection structure for niveles
// ----------------------------
db.getCollection("niveles").drop();
db.createCollection("niveles");

// ----------------------------
// Documents of niveles
// ----------------------------
db.getCollection("niveles").insert([ {
    _id: ObjectId("69e92129ee3e2b6b23011632"),
    nombre: "Bosque oscuro",
    descripcion: "Zona inicial con poca visibilidad",
    dificultad: "baja"
} ]);
db.getCollection("niveles").insert([ {
    _id: ObjectId("69e92133ee3e2b6b23011634"),
    nombre: "Cueva del puente",
    descripcion: "Escenario con plataformas inestables",
    dificultad: "media"
} ]);
db.getCollection("niveles").insert([ {
    _id: ObjectId("69e9213fee3e2b6b23011636"),
    nombre: "Mente fragmentada",
    descripcion: "Entorno abstracto con distorsión visual",
    dificultad: "alta"
} ]);

// ----------------------------
// Collection structure for objetos
// ----------------------------
db.getCollection("objetos").drop();
db.createCollection("objetos");

// ----------------------------
// Documents of objetos
// ----------------------------
db.getCollection("objetos").insert([ {
    _id: ObjectId("69e92024ee3e2b6b23011620"),
    nombre: "Llave",
    descripcion: "Permite abrir caminos bloqueados",
    tipo: "clave"
} ]);
db.getCollection("objetos").insert([ {
    _id: ObjectId("69e9203fee3e2b6b23011622"),
    nombre: "Pastilla",
    descripcion: "Altera el estado mental del personaje",
    tipo: "consumible"
} ]);
db.getCollection("objetos").insert([ {
    _id: ObjectId("69e9204aee3e2b6b23011624"),
    nombre: "Linterna",
    descripcion: "Ilumina zonas oscuras",
    tipo: "herramienta"
} ]);
db.getCollection("objetos").insert([ {
    _id: ObjectId("69e92056ee3e2b6b23011626"),
    nombre: "Nota",
    descripcion: "Contiene fragmentos de la historia",
    tipo: "coleccionable"
} ]);

// ----------------------------
// Collection structure for progreso
// ----------------------------
db.getCollection("progreso").drop();
db.createCollection("progreso");

// ----------------------------
// Documents of progreso
// ----------------------------
db.getCollection("progreso").insert([ {
    _id: ObjectId("69e92172ee3e2b6b23011638"),
    id_usuario: ObjectId("69e9227bee3e2b6b23011644"),
    niveles_completados: [
        {
            nombre: "Bosque oscuro",
            completado: true
        }
    ]
} ]);
db.getCollection("progreso").insert([ {
    _id: ObjectId("69e92181ee3e2b6b2301163a"),
    id_usuario: ObjectId("69e922e3ee3e2b6b23011646"),
    niveles_completados: [
        {
            nombre: "Bosque oscuro",
            completado: true
        },
        {
            nombre: "Cueva del puente",
            completado: true
        }
    ]
} ]);
db.getCollection("progreso").insert([ {
    _id: ObjectId("69e9218dee3e2b6b2301163c"),
    id_usuario: ObjectId("69e9231cee3e2b6b23011648"),
    niveles_completados: [
        {
            nombre: "Bosque oscuro",
            completado: true
        }
    ]
} ]);

// ----------------------------
// Collection structure for usuarios
// ----------------------------
db.getCollection("usuarios").drop();
db.createCollection("usuarios");

// ----------------------------
// Documents of usuarios
// ----------------------------
db.getCollection("usuarios").insert([ {
    _id: ObjectId("69e9227bee3e2b6b23011644"),
    nombre: "Luis",
    email: "luis@gmail.com",
    password: "123456",
    fecha_registro: ISODate("2026-04-22T10:00:00.000Z"),
    nivel_actual: 1,
    estado_mental: "normal"
} ]);
db.getCollection("usuarios").insert([ {
    _id: ObjectId("69e922e3ee3e2b6b23011646"),
    nombre: "Isacc19",
    email: "andymipatrona@gmail.com",
    password: "abcdef",
    fecha_registro: ISODate("2026-04-20T15:30:00.000Z"),
    nivel_actual: 2,
    estado_mental: "alterado"
} ]);
db.getCollection("usuarios").insert([ {
    _id: ObjectId("69e9231cee3e2b6b23011648"),
    nombre: "Brandon",
    email: "debraye@gmail.com",
    password: "toque1",
    fecha_registro: ISODate("2026-04-18T08:45:00.000Z"),
    nivel_actual: 1,
    estado_mental: "critico"
} ]);
