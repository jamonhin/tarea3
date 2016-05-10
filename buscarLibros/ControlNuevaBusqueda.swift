//
//  ControlNuevaBusqueda.swift
//  buscarLibros
//
//  Created by James Montoya on 9/05/16.
//  Copyright © 2016 James Montoya. All rights reserved.
//

import UIKit

class ControlNuevaBusqueda: UIViewController {

    @IBOutlet weak var isbn: UITextField!
    @IBOutlet weak var tituloLibro: UITextField!
    @IBOutlet weak var autoresLibro: UITextField!
    @IBOutlet weak var imagenPortada: UIImageView!
    
    
    var resultadoTitulo: String? = nil
    var resultadoAutores: String? = nil
    var resultadoPortada: String? = nil
    
    @IBAction func consultarLibro(sender: AnyObject) {
        consultar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /**
     * Llamado cuando la tecla "retorno" presionado. NO volver a pasar por alto.
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    /**
     * Se llama cuando el usuario haga clic en la vista (fuera del UITextField).
     */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    func consultar()  {
        
        if  (self.isbn.text != "") {
            
            
            var libro : String?
            
            libro = String(self.isbn.text!)
            
            let urls: String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + libro!
            //print(urls)
            //self.txtResultado.text = "Esperando Respuesta..."
            
            let url = NSURL(string: urls)
            let datos: NSData? = NSData(contentsOfURL: url!)
            let respuesta = NSString(data: datos!, encoding: NSUTF8StringEncoding)
            
            //manejo de errores
            do {
                
                if  String(respuesta) !=   "Optional({})" {
                    
                    let json =  try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
                    let dic1 = json as! NSDictionary
                    let dic2 = dic1["ISBN:" + libro!] as! NSDictionary
                    
                    var autores: String = ""
                    
                    var names = [String]()
                    
                    // Debemos validar si existe la clave authors o cualquier otro nodo del json ya que si no existe nos saldra un error
                    
                    if let _ = dic2["authors"] {
                        //Si existe como nos devuelve un arreglo ya que inicia con [] lo debmos leer asi con un ciclo
                        let dic3 = dic2["authors"] as? [[String: AnyObject]]
                        for dic3 in dic3! {
                            if let name = dic3["name"] as? String {
                                names.append(name)
                            }
                        }
                        for element in names {
                            autores = element + ", " + autores
                        }
                        
                    }
                    else {
                        autores = "No se encontraron autores"
                    }
                    
                    //Busca la portada
                    
                    if let _ = dic2["cover"] {
                        //Si existe como nos devuelve un arreglo ya que inicia con [] lo debmos leer asi con un ciclo
                        let  dic4 = dic2["cover"] as! NSDictionary
                        
                        
                        let urlcoverL = dic4["large"] as! NSString as String
                        
                        self.resultadoPortada = urlcoverL as String
                        
                        let url = NSURL(string: urlcoverL)
                        
                        let data = NSData(contentsOfURL: url!)
                        
                        if (data != nil) {
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                self.imagenPortada.image = UIImage(data: data!)
                                
                            });
                            
                        }

                        
                    }
                    else {
                        //sin portada
                        self.imagenPortada.image = UIImage(named: "Sin_imagen_disponible")
                    }
                    
                    self.tituloLibro.text =   String(dic2["title"]!)
                    self.autoresLibro.text =   autores
                    
                } else {
                    self.tituloLibro.text = "No se encontraron resultados para esta busqueda.."
                }
                
            }
            catch _ {
                self.tituloLibro.text = "Error en la conexion a Internet, Verifique su conexion y vuelva a intentar la tarea"
            }
            
            
        } else {
            
            let alertController = UIAlertController(title: "Mensaje Alerta", message:
                "Debe ingresar un numero ISBN antes de dar clic en la lupa", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Cerrar", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
