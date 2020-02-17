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

************************************************************************************************************************
                                           Traitement des données
************************************************************************************************************************

Après avoir soumis un tel formulaire, les données envoyées sont dans un format binaire "multipart", et sont disponibles
dans le corps de la requête POST.

À ce sujet, une subtilité importante mérite d'être portée à votre attention : ce format de requête n'est pas supporté
par les versions de Tomcat antérieures à 7.0.6. L'explication de ce comportement réside principalement dans :

  * la version de l'API servlet utilisée : ce n'est qu'à partir de Java EE 6 que la version 3.0 du conteneur de servlets
    a été mise en place. L'API en version 2.x ne supporte pas de telles requêtes, elle ne sait gérer que le enctype par
    défaut ;

  * un bug dans les premières éditions de Tomcat 7 : aucun problème en ce qui nous concerne, car les versions récentes ont
    corrigé ce problème.

************************************************************************************************************************
                                                   Avec l'API servlet 2.x
************************************************************************************************************************

Lorsque des données sont envoyées avec le type multipart, les méthodes telles que request.getParameter() retournent
toutes null. Il est en théorie possible d'analyser le corps de la requête vous-mêmes en vous basant sur la méthode
getInputStream() de l'objet HttpServletRequest, mais c'est un vrai travail d’orfèvre qui requiert une parfaite
connaissance de la norme RFC2388 !

Nous n'allons pas étudier en détail la méthode à mettre en place avec cette ancienne version de l'API, mais je vais
tout de même vous donner les éléments principaux pour que vous sachiez par où commencer, si jamais vous devez travailler
un jour sur une application qui tourne sur une version de l'API antérieure à la 3.0.

La coutume est plutôt d'utiliser Apache Commons FileUpload pour parser les données multipart du formulaire. Cette
bibliothèque est une implémentation très robuste de la RFC2388 qui dispose d'excellents guide utilisateur et FAQ
(ressources en anglais, mais je vous recommande de parcourir les deux attentivement si vous travaillez avec cette
version de l'API servlet). Pour l'utiliser, il est nécessaire de placer les fichiers commons-fileupload.jar et
commons-io.jar dans le répertoire /WEB-INF/lib de votre application.

Je vous présente ici succinctement le principe général, mais je ne détaille volontairement pas la démarche et ne
vous fais pas mettre en place d'exemple pratique : vous allez le découvrir un peu plus bas, nous allons utiliser
dans notre projet la démarche spécifique à l'API servlet 3.0. Voici cependant un exemple montrant ce à quoi devrait
ressembler la méthode doPost() de votre servlet d'upload si vous utilisez Apache Commons FileUpload :


      --------------------------------------------------------------------------------------------------
      import org.apache.commons.fileupload.FileItem;
      import org.apache.commons.fileupload.FileUploadException;
      import org.apache.commons.fileupload.disk.DiskFileItemFactory;
      import org.apache.commons.fileupload.servlet.ServletFileUpload;

      public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
          try {
              List<FileItem> items = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
              for (FileItem item : items) {
                  if (item.isFormField()) {
                      /* Traiter les champs classiques ici (input type="text|radio|checkbox|etc", select, etc). */
                      String nomChamp = item.getFieldName();
                      String valeurChamp = item.getString();
                      /* ... (traitement à faire) */
                  } else {
                      /* Traiter les champs de type fichier (input type="file"). */
                      String nomChamp = item.getFieldName();
                      String nomFichier = FilenameUtils.getName(item.getName());
                      InputStream contenuFichier = item.getInputStream();
                      /* ... (traitement à faire) */
                  }
              }
          } catch (FileUploadException e) {
              throw new ServletException("Échec de l'analyse de la requête multipart.", e);
          }

      }
************************************************************************************************************************

Je vous renvoie à la documentation de la bibliothèque si vous souhaitez en apprendre davantage sur son fonctionnement.

En guise d'ouverture pour cette solution, une alternative intéressante à ce système serait d'intégrer tout cela dans
un Filter qui analyserait le contenu automatiquement et réinsérerait le tout dans la Map des paramètres de la requête,
comme s'il s'agissait d'un champ de formulaire classique, rendant ainsi possible de manière transparente :

     * l'utilisation d'un simple request.getParameter() comme lors de la récupération d'un paramètre quelconque ;

     * l'obtention du fichier uploadé via request.getAttribute().

Vous pouvez trouver un tel exemple sur cet excellent article.

************************************************************************************************************************
                                            Avec l'API servlet 3.0
************************************************************************************************************************

En ce qui nous concerne, notre application se base sur l'API servlet 3.0, la solution précédente ne nous est donc pas
nécessaire ! Dans cette dernière mouture, une nouvelle méthode getParts() est mise à disposition dans l'objet
HttpServletRequest, et permet de collecter très simplement les éléments de données de type multipart ! Auparavant,
il était impossible de parvenir à cela simplement sans bibliothèque externe.

Pour la petite histoire, afin de rendre cette fonctionnalité disponible, la plupart des conteneurs implémentant
l'API servlet 3.0 utilisent en réalité le code de la bibliothèque Apache Commons FileUpload dans les coulisses !
C'est notamment le cas de Tomcat 7 (Apache) et de GlassFish 3 (Oracle).

Pour commencer, nous devons compléter la déclaration de notre servlet dans le fichier web.xml avec une section
<multipart-config> afin de faire en sorte que la méthode getParts() fonctionne :

                     -----------------------------------------------------------------------
                     <servlet>
                     	<servlet-name>Upload</servlet-name>
                     	<servlet-class>com.sdzee.servlets.Upload</servlet-class>
                     	<multipart-config>
                     		<location>c:/fichiers</location>
                     		<max-file-size>10485760</max-file-size> <!-- 10 Mo -->
                     		<max-request-size>52428800</max-request-size> <!-- 5 x 10 Mo -->
                     		<file-size-threshold>1048576</file-size-threshold> <!-- 1 Mo -->
                     	</multipart-config>
                     </servlet>
                     -----------------------------------------------------------------------

Vous remarquez que cette section s'ajoute au sein de la balise de déclaration <servlet> de notre servlet d'upload.
Voici une rapide description des paramètres optionnels existants :

    * <location> contient une URL absolue vers un répertoire du système. Un chemin relatif au contexte de l'application
      n'est pas supporté dans cette balise, il s'agit bien là d'un chemin absolu vers le système. Cette URL sera
      utilisée pour stocker temporairement un fichier lors du traitement des fragments d'une requête, lorsque la taille
      du fichier est plus grande que la taille spécifiée dans <file-size-threshold>. Si vous précisez ici un répertoire
      qui n'existe pas sur le disque, alors Tomcat enverra une java.io.IOException lorsque vous tenterez d'envoyer un
      fichier plus gros que cette limite ;

    * <file-size-threshold> précise la taille en octets à partir de laquelle un fichier reçu sera temporairement stocké
      sur le disque ;

    * <max-file-size> précise la taille maximum en octets autorisée pour un fichier envoyé. Si la taille d'un fichier
      envoyé dépasse cette limite, le conteneur enverra une exception. En l'occurrence, Tomcat lancera une
      IllegalStateException ;

    * <max-request-size> précise la taille maximum en octets autorisée pour une requête multipart/form-data. Si la
      taille totale des données envoyées dans une seule requête dépasse cette limite, le conteneur enverra une exception.

************************************************************************************************************************

En paramétrant ainsi notre servlet, toutes les données multipart/form-data seront disponibles à travers la méthode
request.getParts(). Celle-ci retourne une collection d'éléments de type Part, et doit être utilisée en lieu et place
de l'habituelle méthode request.getParameter() pour récupérer les contenus des champs de formulaire.

À l'utilisation, il s'avère que c'est bien plus pratique que d'utiliser directement du pur Apache Commons FileUpload,
comme c'était nécessaire avec les versions antérieures de l'API Servlet ! Par contre, je me répète, mais je viens de
vous annoncer que les contenus des champs du formulaire allaient maintenant être disponibles en tant que collection
d'éléments de type Part et ça, ça va nous poser un petit problème... Car si vous étudiez attentivement l'interface Part,
vous vous rendez compte qu'elle est plutôt limitée en termes d'abstraction : c'est simple, elle ne propose tout bonnement
aucune méthode permettant de déterminer si une donnée reçue renferme un champ classique ou un champ de type fichier !

Dans ce cas, comment savoir si une requête contient des fichiers ?

Heureusement, il va être facile de nous en sortir par nous-mêmes. Afin de déterminer si les données transmises dans
une requête HTTP contiennent d'éventuels fichiers ou non, il suffit d'analyser ses en-têtes. Regardez plutôt ces deux
extraits d'en-tête HTTP (commentés) :

                              --------------------------------------------------------------------
                              // Pour un champ <input type="text"> nommé 'description'
                              Content-Disposition: form-data; name="description"

                              // Pour un champ <input type="file"> nommé 'fichier'
                              Content-Disposition: form-data; name="fichier"; filename="nom_du_fichier.ext"
                              ----------------------------------------------------------------------

Comme vous pouvez le constater, la seule différence est la présence d'un attribut nommé filename. Il suffit donc de
s'assurer qu'un en-tête contient le mot-clé filename pour être certain que le fragment traité est un fichier.

Tout cela est magnifique, mais comment allons-nous récupérer le contenu des en-têtes relatifs à un fragment donné ?

Comme d'habitude, il n'y a pas de miracle : tout est dans la documentation ! :) Encore une fois, si vous étudiez
attentivement l'interface Part, vous constatez qu'elle contient une méthode part.getHeader() qui renvoie l'en-tête
correspondant à un élément. Exactement ce qu'il nous faut !

Ainsi, nous allons pouvoir examiner le contenu des en-têtes relatifs à un fragment et y vérifier la présence du
mot-clé filename, afin de savoir si le champ traité est de type fichier ou non.

Lançons-nous, et implémentons un début de méthode doPost() dans notre servlet d'upload :

--%>

</body>
</html>
