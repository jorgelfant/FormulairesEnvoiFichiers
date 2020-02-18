<%--
  Created by IntelliJ IDEA.
  User: jorge.carrillo
  Date: 2/17/2020
  Time: 1:17 PM
  To change this template use File | Settings | File Templates.
--%>
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
<form action="upload" method="post" enctype="multipart/form-data">
    <fieldset>
        <legend>Envoi de fichier</legend>

        <label for="description">Description du fichier</label>
        <input type="text" id="description" name="description" value="" />
        <span class="succes"><c:out value="${requestScope.description}" /></span>
        <br />

        <label for="fichier">Emplacement du fichier <span class="requis">*</span></label>
        <input type="file" id="fichier" name="fichier" />
        <span class="succes"><c:out value="${fichier}" /></span><%-- pas de requestScope car c'est de type file --%>
        <br />                  <%-- request.getPart(CHAMP_FICHIER)  et non request.getParameter(CHAMP_DESCRIPTION) car file --%>

        <input type="submit" value="Envoyer" class="sansLabel" />
        <br />
    </fieldset>
</form>
</body>
</html>