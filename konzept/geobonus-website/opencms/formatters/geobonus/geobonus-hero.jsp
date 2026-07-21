<%@page pageEncoding="UTF-8" buffer="none" session="false" trimDirectiveWhitespaces="true"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m"   tagdir="/WEB-INF/tags/mercury" %>

<m:init-messages>
<cms:formatter var="content" val="value">
<m:setting-defaults>

<c:set var="ade" value="${cms.isEditMode}" />

<section class="element type-gb-hero hero${setCssWrapperAll}" aria-label="${fn:escapeXml(value.Title)}"><%----%>

    <c:if test="${value.Image.exists}">
        <div class="hero-bg" id="heroBg"><%----%>
            <img src="<cms:link>${value.Image.value.Image}</cms:link>" alt="${fn:escapeXml(value.Image.value.Title)}" loading="eager"><%----%>
        </div><%----%>
    </c:if>
    <div class="hero-scrim"></div><%----%>
    <div class="hero-fade"></div><%----%>

    <div class="wrap hero-content"><%----%>
        <c:if test="${value.Eyebrow.isSet or value.Coords.isSet}">
            <div class="hero-eyebrow-row"><%----%>
                <c:if test="${value.Eyebrow.isSet}">
                    <span class="eyebrow eyebrow--fade"><span class="dot"></span>${value.Eyebrow}</span><%----%>
                </c:if>
                <c:if test="${value.Coords.isSet}">
                    <span class="hero-coords">${value.Coords}</span><%----%>
                </c:if>
            </div><%----%>
        </c:if>

        <h1 ${ade ? content.rdfa.Title : ''}><%----%>
            ${value.Title}<%----%>
            <c:if test="${value.TitleAccent.isSet}"> <em>${value.TitleAccent}</em></c:if><%----%>
        </h1><%----%>

        <c:if test="${value.Subtitle.isSet}">
            <div class="sub" ${ade ? content.rdfa.Subtitle : ''}>${value.Subtitle}</div><%----%>
        </c:if>

        <c:if test="${not empty content.valueList.Cta}">
            <div class="cta-row"><%----%>
                <c:forEach var="cta" items="${content.valueList.Cta}" varStatus="s"><%----%>
                    <m:link link="${cta}" css="btn ${s.first ? 'btn-accent' : 'btn-ghost'}"><%----%
                        %>${cta.value.Text.isSet ? cta.value.Text : value.Title}<%----%
                        %><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg><%----%>
                    </m:link><%----%>
                </c:forEach><%----%>
            </div><%----%>
        </c:if>
    </div><%----%>

</section><%----%>

</m:setting-defaults>
</cms:formatter>
</m:init-messages>
