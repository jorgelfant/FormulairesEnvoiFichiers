package com.sdzee.servlets;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

public class Upload extends HttpServlet {

    public static final String VUE = "/WEB-INF/upload.jsp";

    public static final String CHAMP_DESCRIPTION = "description";
    public static final String CHAMP_FICHIER = "fichier";

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        /* Affichage de la page d'envoi de fichiers */
        this.getServletContext().getRequestDispatcher(VUE).forward(request, response);
    }

    //------------------------------------------------------------------------------------------------------------------
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        /* Récupération du contenu du champ de description */
        String description = request.getParameter(CHAMP_DESCRIPTION);
        request.setAttribute(CHAMP_DESCRIPTION, description);

        //Les données reçues sont multipart, on doit donc utiliser la méthode getPart() pour traiter le champ d'envoi de fichiers.
        Part part = request.getPart(CHAMP_FICHIER);

        // Il faut déterminer s'il s'agit d'un champ classique ou d'un champ de type fichier : on délègue cette opération
        // à la méthode utilitaire getNomFichier().
        String nomFichier = getNomFichier(part);
        // Si la méthode a renvoyé quelque chose, il s'agit donc d'un champ de type fichier (input type="file").
        if (nomFichier != null && !nomFichier.isEmpty()) {
            String nomChamp = part.getName();
            // Antibug pour Internet Explorer, qui transmet pour une raison mystique le
            // chemin du fichier local à la machine du client...
            //
            // Ex : C:/dossier/sous-dossier/fichier.ext
            //
            // On doit donc faire en sorte de ne sélectionner que le nom et
            // l'extension du fichier, et de se débarrasser du superflu.
            nomFichier = nomFichier.substring(nomFichier.lastIndexOf('/') + 1)
                    .substring(nomFichier.lastIndexOf('\\') + 1);

            request.setAttribute(nomChamp, nomFichier);
        }
        this.getServletContext().getRequestDispatcher(VUE).forward(request, response);
    }

    //------------------------------------------------------------------------------------------------------------------
    // Méthode utilitaire qui a pour unique but d'analyser l'en-tête "content-disposition", et de vérifier si le
    // paramètre "filename"  y est présent. Si oui, alors le champ traité est de type File et la méthode retourne
    // son nom, sinon il s'agit d'un champ de formulaire classique et la méthode retourne null.
    private static String getNomFichier(Part part) {
        // Boucle sur chacun des paramètres de l'en-tête "content-disposition".
        for (String contentDisposition : part.getHeader("content-disposition").split(";")) {
            // Recherche de l'éventuelle présence du paramètre "filename".
            if (contentDisposition.trim().startsWith("filename")) {
                // Si "filename" est présent, alors renvoi de sa valeur, c'est-à-dire du nom de fichier sans guillemets.
                return contentDisposition.substring(contentDisposition.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        // Et pour terminer, si rien n'a été trouvé...
        return null;
    }
}