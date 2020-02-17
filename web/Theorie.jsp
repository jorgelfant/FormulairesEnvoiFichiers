<%--
  Created by IntelliJ IDEA.
  User: jorge.carrillo
  Date: 2/17/2020
  Time: 11:47 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
<%--

************************************************************************************************************************
                                       Formulaires : l'envoi de fichiers
************************************************************************************************************************

Nous savons gérer toutes sortes de saisies simples - champs de type texte, case à cocher, liste déroulante,
bouton radio, etc. - mais il nous reste encore à traiter le cas du champ de formulaire permettant l'envoi d'un fichier.
C'est un gros chapitre qui vous attend : il y a beaucoup de choses à découvrir, prenez le temps de bien assimiler toutes
les notions présentées !

************************************************************************************************************************
                                           Création du formulaire
************************************************************************************************************************

Pour permettre au visiteur de naviguer et sélectionner un fichier pour envoi via un champ de formulaire, il faut utiliser
la balise HTML <input type="file">. Pour rappel, et c'est d'ailleurs explicité dans la spécification HTML, pour envoyer
un fichier il faut utiliser la méthode POST lors de l'envoi des données du formulaire. En outre, nous y apprenons que
l'attribut optionnel enctype doit être défini à "multipart/form-data".

Sans plus tarder, créons sous le répertoire /WEB-INF une page upload.jsp qui affichera un tel formulaire à l'utilisateur :

             ------------------------------------------------------------------------------------------------
             <%@ page pageEncoding="UTF-8" %>
             <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
             <!DOCTYPE html>
             <html>
                 <head>
                     <meta charset="utf-8" />
                     <title>Envoi de fichier</title>
                     <link type="text/css" rel="stylesheet" href="<c:url value="/inc/form.css"/>" />
                 </head>
                 <body>
                     <form action="<c:url value="/upload" />" method="post" enctype="multipart/form-data">
                         <fieldset>
                             <legend>Envoi de fichier</legend>

                             <label for="description">Description du fichier</label>
                             <input type="text" id="description" name="description" value="" />
                             <br />

                             <label for="fichier">Emplacement du fichier <span class="requis">*</span></label>
                             <input type="file" id="fichier" name="fichier" />
                             <br />

                             <input type="submit" value="Envoyer" class="sansLabel" />
                             <br />
                         </fieldset>
                     </form>
                 </body>
             </html>
             ------------------------------------------------------------------------------------------

Remarquez bien aux lignes 11 et 20 :

      * l'utilisation de l'attribut optionnel enctype, dont nous n'avions pas besoin dans nos formulaires d'inscription
        et de connexion puisqu'ils contenaient uniquement des champs classiques ;

      * la mise en place d'un champ <input type="file"/> dédié à l'envoi de fichiers.

C'est la seule page nécessaire : j'ai réutilisé la même feuille de style CSS que pour nos précédents formulaires.

************************************************************************************************************************
                                       Récupération des données
************************************************************************************************************************


********************
Mise en place
********************

Vous commencez à être habitués maintenant : l'étape suivante est la mise en place de la servlet associée à cette page.
Il nous faut donc créer une servlet, que nous allons nommer Upload et qui est presque vide pour l'instant :

     ------------------------------------------------------------------------------------------------------
     package com.sdzee.servlets;

     import java.io.IOException;

     import javax.servlet.ServletException;
     import javax.servlet.http.HttpServlet;
     import javax.servlet.http.HttpServletRequest;
     import javax.servlet.http.HttpServletResponse;

     public class Upload extends HttpServlet {
     	public static final String VUE = "/WEB-INF/upload.jsp";

     	public void doGet( HttpServletRequest request, HttpServletResponse response ) throws ServletException, IOException{
     		/* Affichage de la page d'envoi de fichiers */
     		this.getServletContext().getRequestDispatcher( VUE ).forward( request, response );
     	}

     	public void doPost( HttpServletRequest request, HttpServletResponse response ) throws ServletException, IOException{
     		/* Méthode vide, pour l'instant... */
     	}
     }
    ------------------------------------------------------------------------------------------------------------

    Puis l'associer à la requête HTTP émise par le formulaire, en la déclarant dans le web.xml de notre application :

                           ------------------------------------------------
                              <?xml version="1.0" encoding="UTF-8"?>
                              <web-app>
                              	...

                              	<servlet>
                              		<servlet-name>Upload</servlet-name>
                              		<servlet-class>com.sdzee.servlets.Upload</servlet-class>
                              	</servlet>

                              	...

                              	<servlet-mapping>
                              		<servlet-name>Upload</servlet-name>
                              		<url-pattern>/upload</url-pattern>
                              	</servlet-mapping>
                              </web-app>
                           ---------------------------------------------------

Avec une telle configuration, nous pouvons accéder au formulaire en nous rendant depuis notre navigateur
sur http://localhost:8080/pro/upload (voir la figure suivante).

L'étape suivante consiste bien évidemment à compléter notre servlet pour traiter les données reçues !

*************************
Traitement des données
*************************

--%>

</body>
</html>
